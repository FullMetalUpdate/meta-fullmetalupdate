SUMMARY = "Python Qt5 Bindings"
AUTHOR = "Phil Thomson @ riverbank.co.uk"
HOMEPAGE = "http://riverbankcomputing.co.uk"
SECTION = "devel/python"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d32239bcb673463ab874e80d47fae504"

SRC_URI = "\
    https://sourceforge.net/projects/pyqt/files/PyQt5/PyQt-${PV}/PyQt5_gpl-${PV}.tar.gz \
    file://0001-Make-sure-to-find-python3-sip-code-generator.patch \
    file://fix-sm.patch \
    file://0001-qtabbar.sip-fix-build-with-accessibility-disabled.patch \
"
SRC_URI[md5sum] = "c3048e9d242f3e72fd393630da1d971a"
SRC_URI[sha256sum] = "ebd70515b30bbd6098fee29e6271a6696b1183c5530ee30e6ba9aaab195536e8"

PE = "1"

inherit qmake5 python3native

DEPENDS = "sip3-native sip3 qtbase qtquickcontrols2 python3 "

S = "${WORKDIR}/PyQt5_gpl-${PV}"
B = "${S}"

DISABLED_FEATURES = "PyQt_Desktop_OpenGL PyQt_SSL PyQt_SessionManager"

DISABLED_FEATURES_append_arm = " PyQt_qreal_double"

PYQT_MODULES = "QtCore QtGui QtQml QtQuick QtNetwork"
PYQT_MODULES_aarch64 = "QtCore QtGui QtQml QtQuick QtNetwork"

# full paths
SYSROOTDIR = "${STAGING_DIR_HOST}"
SYSROOTDIR_class-native = "${STAGING_DIR_NATIVE}"
INCLUDEDIR = "${STAGING_INCDIR}"
INCLUDEDIR_class-native = "${STAGING_INCDIR_NATIVE}"
LIBDIR = "${STAGING_LIBDIR}"
LIBDIR_class-native = "${STAGING_LIBDIR_NATIVE}"
PYTHONEXEC = "${bindir}/${PYTHON_PN}"
PYTHONEXEC_class-native = "${PYTHON}"

do_configure() {
    echo "py_platform = linux" > pyqt.cfg
    echo "py_inc_dir = ${INCLUDEDIR}/python${PYTHON_BASEVERSION}${PYTHON_ABI}" >> pyqt.cfg
    echo "py_pylib_dir = ${LIBDIR}/python${PYTHON_BASEVERSION}" >> pyqt.cfg
    echo "py_pylib_lib = python${PYTHON_BASEVERSION}${PYTHON_ABI}" >> pyqt.cfg
    echo "pyqt_module_dir = ${D}/${PYTHON_SITEPACKAGES_DIR}" >> pyqt.cfg
    echo "pyqt_bin_dir = ${D}/${bindir}" >> pyqt.cfg
    echo "pyqt_sip_dir = ${D}/${datadir}/sip/PyQt5" >> pyqt.cfg
    echo "pyuic_interpreter = ${PYTHONEXEC}" >> pyqt.cfg
    echo "pyqt_disabled_features = ${DISABLED_FEATURES}" >> pyqt.cfg
    echo "qt_shared = True" >> pyqt.cfg
    QT_VERSION=`${OE_QMAKE_QMAKE} -query QT_VERSION`
    echo "[Qt $QT_VERSION]" >> pyqt.cfg
    echo "pyqt_modules = ${PYQT_MODULES}" >> pyqt.cfg
    echo yes | python3 configure.py --verbose --qmake ${OE_QMAKE_QMAKE} --configuration pyqt.cfg --sysroot ${SYSROOTDIR}
}

do_install() {
     oe_runmake install
}

do_install_class-native() {
     oe_runmake install
}

RDEPENDS_${PN}_append_class-target = " python3-core python3-sip"

FILES_${PN} += " \
    ${libdir}/${PYTHON_DIR}/site-packages \
    ${datadir}/sip/PyQt5 \
"

BBCLASSEXTEND += "native nativesdk"
