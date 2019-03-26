# Copyright (C) 2019 Witekio
# Released under the MIT license (see COPYING.MIT for the terms)
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://busybox-udhcpc.service"

FILES_${PN}-udhcpc += "${systemd_system_unitdir}/busybox-udhcpc.service"
SYSTEMD_PACKAGES += "${PN}-udhcpc"
SYSTEMD_SERVICE_${PN}-udhcpc = "busybox-udhcpc.service"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/busybox-udhcpc.service ${D}${systemd_system_unitdir}/
}
