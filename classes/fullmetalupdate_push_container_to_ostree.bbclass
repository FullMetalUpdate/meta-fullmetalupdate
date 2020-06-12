inherit fullmetalupdate

# OSTree application deployment
export OSTREE_PACKAGE_BRANCHNAME = "${PN}"
export OSTREE_REPO_CONTAINERS = "${DEPLOY_DIR_IMAGE}/ostree_repo_containers"

do_push_container_to_ostree_and_hawkbit[depends] = " \
    curl-native:do_populate_sysroot \
    ostree-native:do_populate_sysroot \
"

do_push_container_to_ostree_and_hawkbit() {
    if [ -z "$OSTREE_PACKAGE_BRANCHNAME" ]; then
        bbfatal "OSTREE_PACKAGE_BRANCHNAME should be set in your local.conf"
    fi

    if [ ! -z "${NOTIFY}" ]; then
        test -z ${TIMEOUT} && err_msg="\n\tTIMEOUT should be set to a positive delay"
        test -z ${AUTOSTART} && AUTOSTART="1"
        test ${AUTOSTART} = "0" && err_msg="$err_msg\n\tAUTOSTART cannot be set to 0 if NOTIFY is set"
        test -z ${err_msg} || bbfatal "NOTIFY is set, but these variables are misconfigured:$err_msg"
    fi

    ostree_init_if_non_existent ${OSTREE_REPO_CONTAINERS} archive-z2

    # Add missing remotes
    ostree_remote_add_if_not_present ${OSTREE_REPO_CONTAINERS} ${OSTREE_PACKAGE_BRANCHNAME} ${OSTREE_HTTP_ADDRESS}

    #Pull locally the remote repo
    set +e
    # Ignore error for this command, since the remote repo could be empty and we have no way to know
    bbnote "Pull locally the repository: ${OSTREE_PACKAGE_BRANCHNAME}"
    ostree_pull_mirror ${OSTREE_REPO_CONTAINERS} ${OSTREE_PACKAGE_BRANCHNAME} ${OSTREE_MIRROR_PULL_DEPTH} ${OSTREE_MIRROR_PULL_RETRIES}
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
    json=$(curl_post "/" '[ { "vendor" : "'${HAWKBIT_VENDOR_NAME}'", "name" : "'${OSTREE_PACKAGE_BRANCHNAME}'", "description" : "'$OSTREE_PACKAGE_BRANCHNAME'", "type" : "application", "version" : "'$(date +%Y%m%d%H%M)'" } ]')
    prop='id'
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    id=$(echo ${temp##*|})
    id=$(echo "$id" | tr -d id: | tr -d ])

    hawkbit_metadata_revparse=$(hawkbit_metadata_value 'rev' ${OSTREE_REVPARSE})
    hawkbit_metadata_autostart=$(hawkbit_metadata_value 'autostart' ${AUTOSTART})
    hawkbit_metadata_screenused=$(hawkbit_metadata_value 'screenused' ${SCREENUSED})
    hawkbit_metadata_autoremove=$(hawkbit_metadata_value 'autoremoved' ${AUTOREMOVE})
    test -z ${NOTIFY} || hawkbit_metadata_notify=$(hawkbit_metadata_value 'notify' ${NOTIFY})
    test -z ${TIMEOUT} || hawkbit_metadata_timeout=$(hawkbit_metadata_value 'timeout' ${TIMEOUT})

    # Push the reference of the OSTree commit to Hawkbit
    curl_post "/${id}/metadata" "${hawkbit_metadata_revparse}"
    # Push if the container should be automatically started to Hawkbit
    curl_post "/${id}/metadata" "${hawkbit_metadata_autostart}"
    # Push if the container is using the screen
    curl_post "/${id}/metadata" "${hawkbit_metadata_screenused}"
    # Push if the container should be removed from the embedded system to Hawkbit
    curl_post "/${id}/metadata" "${hawkbit_metadata_autoremove}"
    # Push if the container should implement the systemd notify feature and rollback
    test -z ${NOTIFY} || curl_post "/${id}/metadata" "${hawkbit_metadata_notify}"
    test -z ${TIMEOUT} || curl_post "/${id}/metadata" "${hawkbit_metadata_timeout}"
}

# do_copy_container task defined in oci_image.bbclass
addtask do_push_container_to_ostree_and_hawkbit after do_copy_container before do_build
