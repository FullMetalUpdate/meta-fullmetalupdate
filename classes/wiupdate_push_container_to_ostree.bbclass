inherit fullmetalupdate

# OSTree application deployment
export OSTREE_PACKAGE_BRANCHNAME = "${PN}"
export OSTREE_REPO_CONTAINERS = "${DEPLOY_DIR_IMAGE}/ostree_repo_containers"

do_push_container_to_ostree_and_hawkbit() {

    if [ -z "$OSTREE_PACKAGE_BRANCHNAME" ]; then
        bbfatal "OSTREE_PACKAGE_BRANCHNAME should be set in your local.conf"
    fi

    ostree_init_if_non_existent ${OSTREE_REPO_CONTAINERS} archive-z2

    # Add missing remotes
    ostree_remote_add_if_not_present ${OSTREE_REPO_CONTAINERS} ${OSTREE_PACKAGE_BRANCHNAME} ${OSTREE_HTTP_ADDRESS}

    #Pull locally the remote repo
    set +e
    # Ignore error for this command, since the remote repo could be empty and we have no way to know
    bbnote "Pull locally the repository: ${OSTREE_PACKAGE_BRANCHNAME}"
    ostree_pull ${OSTREE_REPO_CONTAINERS} ${OSTREE_PACKAGE_BRANCHNAME}
    set -e

    # Commit the result
    bbnote "Commit locally the build result"
    ostree --repo=${OSTREE_REPO_CONTAINERS} commit \
           --tree=tar=${CONTAINERS_DIRECTORY}/${IMAGE_LINK_NAME}.tar.gz \
           --skip-if-unchanged \
           --branch=${OSTREE_PACKAGE_BRANCHNAME} \
           --subject="Commit-id: ${IMAGE_NAME}${IMAGE_NAME_SUFFIX}"

    ostree_push ${OSTREE_REPO_CONTAINERS} ${OSTREE_PACKAGE_BRANCHNAME}

    # Post the newly created container information to hawkbit
    OSTREE_REVPARSE=$(ostree_revparse ${OSTREE_REPO_CONTAINERS} ${OSTREE_PACKAGE_BRANCHNAME})
    # Push the container information to Hawkbit
    json=$(curl ${HAWKBIT_HTTP_ADDRESS}'/rest/v1/softwaremodules' -i -X POST --user admin:admin -H 'Content-Type: application/hal+json;charset=UTF-8' -d '[ {
    "vendor" : "'${HAWKBIT_VENDOR_NAME}'",
    "name" : "'${OSTREE_PACKAGE_BRANCHNAME}'",
    "description" : "'$OSTREE_PACKAGE_BRANCHNAME'",
    "type" : "application",
    "version" : "'$(date +%Y%m%d%H%M)'"
    } ]')
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
    # Push if the container should be automatically started to Hawkbit
    curl ${HAWKBIT_HTTP_ADDRESS}'/rest/v1/softwaremodules/'${id}'/metadata' -i -X POST --user admin:admin -H 'Content-Type: application/hal+json;charset=UTF-8' -d '[ {
    "targetVisible" : true,
    "value" : "'${AUTOSTART}'",
    "key" : "'autostart'"
    } ]'
    # Push if the container is using the screen
    curl ${HAWKBIT_HTTP_ADDRESS}'/rest/v1/softwaremodules/'${id}'/metadata' -i -X POST --user admin:admin -H 'Content-Type: application/hal+json;charset=UTF-8' -d '[ {
    "targetVisible" : true,
    "value" : "'${SCREENUSED}'",
    "key" : "'screenused'"
    } ]'
    # Push if the container should be removed from the embedded system to Hawkbit
    curl ${HAWKBIT_HTTP_ADDRESS}'/rest/v1/softwaremodules/'${id}'/metadata' -i -X POST --user admin:admin -H 'Content-Type: application/hal+json;charset=UTF-8' -d '[ {
    "targetVisible" : true,
    "value" : "'${AUTOREMOVE}'",
    "key" : "'autoremove'"
    } ]'
}

# do_copy_container task defined in oci_image.bbclass
addtask do_push_container_to_ostree_and_hawkbit after do_copy_container before do_build
