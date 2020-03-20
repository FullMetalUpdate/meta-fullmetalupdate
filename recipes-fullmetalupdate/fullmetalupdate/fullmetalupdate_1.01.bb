# Copyright (C) 2019 Witekio
# Released under the GNU LESSER GENERAL PUBLIC LICENSE Version 2.1 license

DESCRIPTION = "FullMetalUpdate Python daemon"
LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/LGPL-2.1;md5=1a6d268fd218675ffea8be556788b780"

inherit systemd

RDEPENDS_${PN} += " \
    ostree \
    python3 \
    python3-aiohttp \
    systemd \
    dbus \
    python3-pydbus \
    python3-pygobject \
    u-boot-fw-utils \
    socat \
"

SRC_URI += " \
    git://github.com/FullMetalUpdate/fullmetalupdate.git;tag=v${PV} \
    file://config.cfg \
    file://fullmetalupdate.sh \
    file://fullmetalupdate.service \
"

FILES_${PN} += " \
    ${base_prefix}/usr/fullmetalupdate \
    ${base_prefix}/usr/fullmetalupdate.service \
"

SYSTEMD_SERVICE_${PN} = "fullmetalupdate.service"

do_install() {
    install -d ${D}${base_prefix}/usr/fullmetalupdate/
    cp -r --no-dereference --preserve=mode,links -v ${WORKDIR}/git/* ${D}${base_prefix}/usr/fullmetalupdate/
    rm -rf ${D}${base_prefix}/usr/fullmetalupdate/.git/

    install -m 755 ${WORKDIR}/config.cfg ${D}${base_prefix}/usr/fullmetalupdate/rauc_hawkbit/config.cfg
    install -m 755 ${WORKDIR}/fullmetalupdate.sh ${D}${base_prefix}/usr/fullmetalupdate/fullmetalupdate.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644  ${WORKDIR}/fullmetalupdate.service ${D}${systemd_system_unitdir}
}
