# Copyright (C) 2019 Witekio
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "FullMetalUpdate Python daemon"
LICENSE = "MIT"

inherit systemd

RDEPENDS_${PN} += " \
    ostree \
    python3 \
    python3-aiohttp \
    systemd \
    dbus \
    python3-pydbus \
    python3-pygobject \
"

SRC_URI += " \
    git://github.com/FullMetalUpdate/fullmetalupdate.git;tag=v${PV} \
    file://config.cfg \
    file://fullmetalupdate.sh \
    file://fullmetalupdate.service \
"

FILES_${PN} += " \
    ${base_prefix}/bin/fullmetalupdate \
    ${base_prefix}/bin/fullmetalupdate.service \
"

SYSTEMD_SERVICE_${PN} = "fullmetalupdate.service"

do_install() {
    install -d ${D}${base_prefix}/bin/fullmetalupdate/
    cp -r --no-dereference --preserve=mode,links -v ${WORKDIR}/git/* ${D}${base_prefix}/bin/fullmetalupdate/
    rm -rf ${D}${base_prefix}/bin/fullmetalupdate/.git/

    install -m 755 ${WORKDIR}/config.cfg ${D}${base_prefix}/bin/fullmetalupdate/rauc_hawkbit/config.cfg
    install -m 755 ${WORKDIR}/fullmetalupdate.sh ${D}${base_prefix}/bin/fullmetalupdate/fullmetalupdate.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644  ${WORKDIR}/fullmetalupdate.service ${D}${systemd_system_unitdir}
}
