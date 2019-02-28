# Copyright (C) 2019 Witekio
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Implementation of the PEP 3156 Event-Loop with Qt"
HOMEPAGE = "https://github.com/gmarull/asyncqt"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-2-Clause;md5=8bef8e6712b1be5aa76af1ebde9d6378"

SRC_URI[sha256sum] = "8b1507c968c85cf0b7eee5d2a887162d38af15fb8c5b1ec25beed6025d7383ac"
PYPI_PACKAGE = "asyncqt"

SRC_URI += " \
    file://0001-Use-QTGui-instead-of-QtWidgets-to-hanlde-QT-applicat.patch \
"

RDEPENDS_${PN} = "python3-pyqt5 python3-asyncio"

do_compile_prepend() {
    export QT_API="PyQt5"
}

inherit pypi setuptools3
