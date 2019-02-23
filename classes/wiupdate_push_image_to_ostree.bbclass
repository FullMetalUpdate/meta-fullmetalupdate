do_push_image_to_hawkbit_and_ostree[recrdeptask] = "do_pull_remote_ostree_image"

do_pull_remote_ostree_image() {

    if [ ! -e "${HAWKBIT_CONFIG_FILE}" ]; then
      bbfatal "config.cfg is missing in the TMP directory. It should never   \
      happen, are you using the docker container to build the images? If not \
      you need to create manually the config.cfg. Check how it's done by the \
      container_run.sh script."
    else
      CFG_CONTENT=$(cat ${HAWKBIT_CONFIG_FILE} | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g' | sed -r '/gpg-verify+/d')
      eval "$CFG_CONTENT"
    fi

    #Initialize the ostree directory if needed
    if [ ! -d ${OSTREE_REPO} ]; then
        ostree --repo=${OSTREE_REPO} init --mode=archive-z2
    fi

    #Add missing remotes
    refs=$(ostree remote list --repo=${OSTREE_REPO} | awk '{if ($0=="${OSTREE_BRANCHNAME}") print $0}')
    
    if [ -z "$refs" ]; then
        bbnote "Add the remote for the container: ${OSTREE_BRANCHNAME}"
        if [ "$ostree_ssl" = "true" ];
        then
            export url_type_ostree="https://"
        else
            export url_type_ostree="http://"
        fi
        ostree remote add --no-gpg-verify ${OSTREE_BRANCHNAME} ${url_type_ostree}${OSTREE_HOSTNAME}':'${ostree_url_port}  --repo=${OSTREE_REPO}
    else
        bbnote "The remote for the container: ${OSTREE_BRANCHNAME} already exists" 
    fi

    #Pull locally the remote repo
    set +e
    #Ignore error for this command, since the remote repo could be empy and we have no way to know
    bbnote "Pull locally the repository: ${OSTREE_BRANCHNAME}"
    ostree pull ${OSTREE_BRANCHNAME} ${OSTREE_BRANCHNAME} --depth=-1 --mirror --repo=${OSTREE_REPO}
    set -e
}

do_push_image_to_hawkbit_and_ostree() {

    if [ ! -e "${HAWKBIT_CONFIG_FILE}" ]; then
      bbfatal "config.cfg is missing in the TMP directory. It should never   \
      happen, are you using the docker container to build the images? If not \
      you need to create manually the config.cfg. Check how it's done by the \
      container_run.sh script."
    else
      CFG_CONTENT=$(cat ${HAWKBIT_CONFIG_FILE} | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g' | sed -r '/gpg-verify+/d')
      eval "$CFG_CONTENT"
    fi

    # Push the result to the remote OSTREE   
    sshpass -p ${ostreepush_ssh_pwd} ostree-push --repo ${OSTREE_REPO} ssh://${ostreepush_ssh_user}@${OSTREE_HOSTNAME}':'${OSTREE_SSHPORT}/ostree/repo/ ${OSTREE_BRANCHNAME}

    if [ "$hawkbit_ssl" = "true" ]; then
        export url_type_hawkbit="https://"
    else
        export url_type_hawkbit="http://"
    fi
    OSTREE_REVPARSE=$(ostree rev-parse ${OSTREE_BRANCHNAME} --repo=${OSTREE_REPO}| head)
    json=$(curl ${url_type_hawkbit}${HAWKBIT_HOSTNAME}':'${hawkbit_url_port}'/rest/v1/softwaremodules' -i -X POST --user admin:admin -H 'Content-Type: application/hal+json;charset=UTF-8' -d '[ {
    "vendor" : "'${vendor_name}'",
    "name" : "'${OSTREE_BRANCHNAME}'-'${MACHINE}'",
    "description" : "'${OSTREE_BRANCHNAME}'",
    "type" : "os",
    "version" : "'$(date +%Y%m%d%H%M)'"} ]')
    prop='id'
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    id=$(echo ${temp##*|})
    id=$(echo "$id" | tr -d id: | tr -d ])
    # Push the reference of the OSTree commit to Hawkbit
    curl ${url_type_hawkbit}${HAWKBIT_HOSTNAME}':'${hawkbit_url_port}'/rest/v1/softwaremodules/'${id}'/metadata' -i -X POST --user admin:admin -H 'Content-Type: application/hal+json;charset=UTF-8' -d '[ {
    "targetVisible" : true,
    "value" : "'${OSTREE_REVPARSE}'",
    "key" : "'rev'"
    } ]'
}

addtask do_push_image_to_hawkbit_and_ostree after do_image_ostree before do_image_ostreepush
addtask do_pull_remote_ostree_image after do_rootfs before do_image_ostree
