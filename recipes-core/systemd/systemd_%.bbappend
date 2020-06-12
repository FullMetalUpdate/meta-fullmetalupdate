# Copyright (C) 2019 Witekio
# Released under the MIT license (see COPYING.MIT for the terms)
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://override.conf \
    file://autorollback \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/emergency.service.d/
    install -d ${D}${sysconfdir}/systemd/system/rescue.service.d/
    install -m 0644 ${WORKDIR}/override.conf ${D}${sysconfdir}/systemd/system/emergency.service.d/override.conf
    install -m 0644 ${WORKDIR}/override.conf ${D}${sysconfdir}/systemd/system/rescue.service.d/override.conf
    install -m 0755 ${WORKDIR}/autorollback ${D}${libdir}/systemd/autorollback
}

