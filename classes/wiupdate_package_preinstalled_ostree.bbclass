inherit fullmetalupdate

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
    ostree_init ${IMAGE_ROOTFS}/ostree_repo bare-user-only
}

do_create_containers_package() {

    for container in ${PREINSTALLED_CONTAINERS_LIST}; do
        bbnote "Add a local remote on the local Docker network for ostree : ${container} ${OSTREE_HTTP_ADDRESS} "
        ostree remote add --no-gpg-verify ${container} ${OSTREE_HTTP_ADDRESS} --repo=${IMAGE_ROOTFS}/ostree_repo
        bbnote "Pull the container: ${container} from the repo"
        ostree_pull ${IMAGE_ROOTFS}/ostree_repo ${container}
        bbnote "Delete the remote on the local docker network from the repo"
        ostree remote delete ${container} --repo=${IMAGE_ROOTFS}/ostree_repo 
        bbnote "Add a distant remote for ostree : ${OSTREE_HTTP_DISTANT_ADDRESS}"
        ostree remote add --no-gpg-verify ${container} ${OSTREE_HTTP_DISTANT_ADDRESS} --repo=${IMAGE_ROOTFS}/ostree_repo
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
