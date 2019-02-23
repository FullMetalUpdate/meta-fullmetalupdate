LICENSE ?= "MIT"

PREINSTALLED_CONTAINERS_LIST ?= ""

CONTAINERS_PACKAGE_NAME = "apps"

#Add dependencies to all containers
python() {
    dependencies = " " + containers_get_dependency(d)
    d.appendVarFlag('do_initialize_ostree_containers', 'depends', dependencies)
    d.appendVarFlag('do_create_containers_package', 'depends', dependencies)
}

def containers_get_dependency(d):
    dependencies = []
    containers = (d.getVar('PREINSTALLED_CONTAINERS_LIST', True) or "").split()
    for container in containers:
        if container not in dependencies:
            dependencies.append(container)

    dependencies_string = ""
    for dependency in dependencies:
        dependencies_string += " " + dependency + ":do_build"
    return dependencies_string

do_initialize_ostree_containers() {
    rm -rf ${WORKDIR}/${CONTAINERS_PACKAGE_NAME}
    rm -rf ${IMAGE_ROOTFS}
    mkdir -p ${IMAGE_ROOTFS}
    rm -f ${WORKDIR}/${PN}-manifest

    bbnote "Initializing a new ostree : ${IMAGE_ROOTFS}/ostree_repo"
    ostree init --repo=${IMAGE_ROOTFS}/ostree_repo --mode=bare-user-only
}

do_create_containers_package() {

    if [ ! -e "${HAWKBIT_CONFIG_FILE}" ]; then
      bbfatal "config.cfg is missing in the TMP directory. It should never   \
      happen, are you using the docker container to build the images? If not \
      you need to create manually the config.cfg. Check how it's done by the \
      container_run.sh script."
    else
        CFG_CONTENT=$(cat ${HAWKBIT_CONFIG_FILE} | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g' | sed -r '/gpg-verify+/d')
        eval "$CFG_CONTENT"
    fi

    if [ "$ostree_ssl" = "true" ]; then
        export url_type_ostree="https://"
    else
        export url_type_ostree="http://"
    fi

    for container in ${PREINSTALLED_CONTAINERS_LIST}; do
        bbnote "Add a local remote on the local Docker network for ostree : ${container} ${url_type_ostree}${OSTREE_HOSTNAME}':'${ostree_url_port} "
        ostree remote add --no-gpg-verify ${container} ${url_type_ostree}${OSTREE_HOSTNAME}':'${ostree_url_port}  --repo=${IMAGE_ROOTFS}/ostree_repo
        bbnote "Pull the container: ${container} from the repo"
        ostree pull ${container} ${container} --repo=${IMAGE_ROOTFS}/ostree_repo 
        bbnote "Delete the remote on the local docker network from the repo"
        ostree remote delete ${container} --repo=${IMAGE_ROOTFS}/ostree_repo 
        bbnote "Add a distant remote for ostree : ${server_host_name}'.local:'${ostree_url_port}"
        ostree remote add --no-gpg-verify ${container} ${server_host_name}'.local:'${ostree_url_port} --repo=${IMAGE_ROOTFS}/ostree_repo
        echo ${container} >> ${IMAGE_ROOTFS}/${IMAGE_NAME}-containers.manifest
    done

    ln -sf ${IMAGE_NAME}-containers.manifest ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}-containers.manifest
}

do_copy_container() {
    mkdir -p ${CONTAINERS_DIRECTORY}
    for type in ${IMAGE_FSTYPES}; do
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.${type} ${CONTAINERS_DIRECTORY}/.
    done
}

addtask create_containers_package after do_rootfs before do_image
addtask copy_container after do_image_complete before do_build

#Allow us to generate image using IMAGE_FSTYPES
inherit image

#Remove useless task
fakeroot python do_rootfs() {
}

addtask do_initialize_ostree_containers after do_rootfs before do_create_containers_package

do_image[noexec] = "1"
do_image_qa[noexec] = "1"
