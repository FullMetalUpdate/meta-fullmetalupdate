# Class to create tarball for a container
#
# The tarball will have the following architecture:
# - ./config.json
# - ./rootfs/<rest of rootfs>

ROOTFS_BOOTSTRAP_INSTALL = ""
KERNELDEPMODDEPEND = ""
IMAGE_LINGUAS = ""

ROOTFS_POSTPROCESS_COMMAND += "oci_tarball_creation_hook; "

CONTAINER_IMAGE_ROOTFS = "${WORKDIR}/ROOTFS_FINAL_FOR_RUNC"

#
# A hook function to shrink oci images generates by yocto
#
oci_tarball_creation_hook() {

        mkdir -p ${CONTAINERS_DIRECTORY}

        bbnote "Creating a New rootfs folder for container : ${CONTAINER_IMAGE_ROOTFS}"
        mkdir -p "${CONTAINER_IMAGE_ROOTFS}"

        bbnote "Copying old rootfs to ${CONTAINER_IMAGE_ROOTFS}"
        cp -R "${IMAGE_ROOTFS}/" "${CONTAINER_IMAGE_ROOTFS}/"
        bbnote "Copying start up file for the container to ${CONTAINER_IMAGE_ROOTFS}/${IMAGE_ROOTFS}"
        cp ${CONTAINER_STARTUP} "${CONTAINER_IMAGE_ROOTFS}/rootfs/entry.sh"
        chmod 755 "${CONTAINER_IMAGE_ROOTFS}/rootfs/entry.sh"
        bbnote "Copy runc json config ${RUNC_CONFIG} at top of ${CONTAINER_IMAGE_ROOTFS}/"
        cp ${RUNC_CONFIG} "${CONTAINER_IMAGE_ROOTFS}/config.json"
        bbnote "Copy  systemd service config ${SYSTEMD_CONFIG} at top of ${CONTAINER_IMAGE_ROOTFS}/"
        cp ${SYSTEMD_CONFIG} "${CONTAINER_IMAGE_ROOTFS}/systemd.service"
        if [ "${AUTOSTART}" -eq "1" ]; then
             bbnote "Create an auto.start file at top of ${CONTAINER_IMAGE_ROOTFS}/"
             touch "${CONTAINER_IMAGE_ROOTFS}/auto.start"
        fi
        if [ "${SCREENUSED}" -eq "1" ]; then
             bbnote "Create an screen.used file at top of ${CONTAINER_IMAGE_ROOTFS}/"
             touch "${CONTAINER_IMAGE_ROOTFS}/screen.used"
        fi

        # remove useless files (update-alternatives, terminfo, bashbug, /etc/...)
        rm -rf ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/lib/opkg \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/cache/dnf/ \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/lib/dnf \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/dnf \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/bin/update-alternatives \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/rpm \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/terminfo \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/default/usbd \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/mtab \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/motd \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/default \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/filesystems \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/fstab \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/host.conf \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/hostname \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/issue \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/issue.net \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/profile \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/shells \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/skel \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/rcS.d \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/etc/init.d \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/tmp \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/lib/rpm \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/lib/smart \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/log \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/run \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/lock \
        ${CONTAINER_IMAGE_ROOTFS}/rootfs/oe_install \


        # remove unless folder if nothing are inside
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/boot && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/boot
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/home/root && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/home/root
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/home && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/home
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/tmp && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/tmp
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/mnt && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/mnt
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/sys && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/sys
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/run && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/run
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/include && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/include
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/sbin && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/sbin
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/bin && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/bin
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/lib && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/lib
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share/dict && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share/dict
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share/man && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share/man
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share/misc && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share/misc
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share/info && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share/info
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/share
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/games && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/games
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/src && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr/src
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/usr
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/media && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/media
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/volatile && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/volatile
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/local && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/local
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/spool && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/spool
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/backups && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/backups
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/lib/misc && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/lib/misc
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/lib && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/var/lib
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/var && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/var
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/oe_install/tmp && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/oe_install/tmp
        test -f ${CONTAINER_IMAGE_ROOTFS}/rootfs/oe_install/tmp && rmdir --ignore-fail-on-non-empty ${CONTAINER_IMAGE_ROOTFS}/rootfs/oe_install


        return 0
}

do_copy_container() {
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.tar.gz ${CONTAINERS_DIRECTORY}/.
}

inherit image image-container

addtask copy_container after do_image_complete before do_build

#Force tar command to use correct rootfs
IMAGE_CMD_tar = "${IMAGE_CMD_TAR} -cvf ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.tar -C ${CONTAINER_IMAGE_ROOTFS} ."

IMAGE_FSTYPES = "tar.gz"
