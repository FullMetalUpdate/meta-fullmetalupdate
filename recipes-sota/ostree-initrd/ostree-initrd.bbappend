# Copyright (C) 2019 Witekio
# Released under the GNU LESSER GENERAL PUBLIC LICENSE Version 2.1 license

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://reboot_on_failure.patch;patchdir=${WORKDIR} \
"
