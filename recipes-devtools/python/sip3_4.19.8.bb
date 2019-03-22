SUMMARY = "SIP is a C++/Python Wrapper Generator"
HOMEPAGE = "http://www.riverbankcomputing.co.uk/sip"
SECTION = "devel"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://LICENSE-GPL2;md5=e91355d8a6f8bd8f7c699d62863c7303"

inherit python3-dir

DEPENDS = "python3"

SRC_URI = "${SOURCEFORGE_MIRROR}/project/pyqt/sip/sip-${PV}/sip-${PV}.tar.gz"
SRC_URI[md5sum] = "0625fb20347d4ff1b5da551539be0727"
SRC_URI[sha256sum] = "7eaf7a2ea7d4d38a56dd6d2506574464bddf7cf284c960801679942377c297bc"
BPN = "sip"

BBCLASSEXTEND = "native"

PACKAGES += "python3-sip"

do_configure_prepend_class-target() {
    echo "py_platform = linux" > sip.cfg
    echo "py_inc_dir = %(sysroot)/${includedir}/python${PYTHON_BASEVERSION}${PYTHON_ABI}" >> sip.cfg
    echo "sip_bin_dir = ${D}/${bindir}" >> sip.cfg
    echo "sip_inc_dir = ${D}/${includedir}" >> sip.cfg
    echo "sip_module_dir = ${D}/${libdir}/python${PYTHON_BASEVERSION}/site-packages" >> sip.cfg
    echo "sip_sip_dir = ${D}/${datadir}/sip" >> sip.cfg
    python3 configure.py --configuration sip.cfg --sysroot ${STAGING_DIR_HOST} CC="${CC}" CXX="${CXX}" LINK="${CXX}" STRIP="" LINK_SHLIB="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LFLAGS="${LDFLAGS}"
}
do_configure_prepend_class-native() {
    echo "py_platform = linux" > sip.cfg
    echo "py_inc_dir = ${includedir}/python${PYTHON_BASEVERSION}${PYTHON_ABI}" >> sip.cfg
    echo "sip_bin_dir = ${D}/${bindir}" >> sip.cfg
    echo "sip_inc_dir = ${D}/${includedir}" >> sip.cfg
    echo "sip_module_dir = ${D}/${libdir}/python${PYTHON_BASEVERSION}/site-packages" >> sip.cfg
    echo "sip_sip_dir = ${D}/${datadir}/sip" >> sip.cfg
    python3 configure.py --configuration sip.cfg --sysroot ${STAGING_DIR_NATIVE}
}
do_install() {
    oe_runmake install
    # avoid conflicts with sip for python2
    mv ${D}/${bindir}/sip ${D}/${bindir}/sip3
}

FILES_python3-sip = "${libdir}/${PYTHON_DIR}/site-packages/"
FILES_${PN}-dbg += "${libdir}/${PYTHON_DIR}/site-packages/.debug"
