inherit fullmetalupdate

do_push_image_to_hawkbit_and_ostree[recrdeptask] = "do_pull_remote_ostree_image"

do_pull_remote_ostree_image() {

    ostree_init_if_non_existent ${OSTREE_REPO} archive-z2

    # Add missing remotes
    ostree_remote_add_if_not_present ${OSTREE_REPO} ${OSTREE_BRANCHNAME} ${OSTREE_HTTP_ADDRESS}

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
    json=$(curl_post "/" '[ { "vendor" : "'${HAWKBIT_VENDOR_NAME}'", "name" : "'${OSTREE_BRANCHNAME}'-'${MACHINE}'", "description" : "'${OSTREE_BRANCHNAME}'", "type" : "os", "version" : "'$(date +%Y%m%d%H%M)'"} ]')
    prop='id'
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    id=$(echo ${temp##*|})
    id=$(echo "$id" | tr -d id: | tr -d ])
    # Push the reference of the OSTree commit to Hawkbit
    curl_post "${id}/metadata" '[ { "targetVisible" : true, "value" : "'${OSTREE_REVPARSE}'", "key" : "'rev'" } ]'
}

addtask do_push_image_to_hawkbit_and_ostree after do_image_ostree before do_image_ostreepush
addtask do_pull_remote_ostree_image after do_rootfs before do_image_ostree
