inherit fullmetalupdate

do_push_image_to_hawkbit_and_ostree[recrdeptask] = "do_pull_remote_ostree_image"

do_pull_remote_ostree_image() {

    #Initialize the ostree directory if needed
    if [ ! -d ${OSTREE_REPO} ]; then
        ostree --repo=${OSTREE_REPO} init --mode=archive-z2
    fi

    #Add missing remotes
    refs=$(ostree remote list --repo=${OSTREE_REPO} | awk '{if ($0=="${OSTREE_BRANCHNAME}") print $0}')
    
    if [ -z "$refs" ]; then
        bbnote "Add the remote for the container: ${OSTREE_BRANCHNAME}"
        ostree remote add --no-gpg-verify ${OSTREE_BRANCHNAME} ${OSTREE_HTTP_ADDRESS} --repo=${OSTREE_REPO}
    else
        bbnote "The remote for the container: ${OSTREE_BRANCHNAME} already exists" 
    fi

    #Pull locally the remote repo
    set +e
    # Ignore error for this command, since the remote repo could be empty and we have no way to know
    bbnote "Pull locally the repository: ${OSTREE_BRANCHNAME}"
    ostree_pull ${OSTREE_REPO} ${OSTREE_BRANCHNAME}
    set -e
}

do_push_image_to_hawkbit_and_ostree() {
    ostree_push ${OSTREE_REPO} ${OSTREE_BRANCHNAME}

    OSTREE_REVPARSE=$(ostree_revparse ${OSTREE_REPO} ${OSTREE_BRANCHNAME})
    json=$(curl ${HAWKBIT_HTTP_ADDRESS}'/rest/v1/softwaremodules' -i -X POST --user admin:admin -H 'Content-Type: application/hal+json;charset=UTF-8' -d '[ {
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
    curl ${HAWKBIT_HTTP_ADDRESS}'/rest/v1/softwaremodules/'${id}'/metadata' -i -X POST --user admin:admin -H 'Content-Type: application/hal+json;charset=UTF-8' -d '[ {
    "targetVisible" : true,
    "value" : "'${OSTREE_REVPARSE}'",
    "key" : "'rev'"
    } ]'
}

addtask do_push_image_to_hawkbit_and_ostree after do_image_ostree before do_image_ostreepush
addtask do_pull_remote_ostree_image after do_rootfs before do_image_ostree
