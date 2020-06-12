include runc.inc

SRCREV = "58415b4b12650291f435db8770cea48207b78afe"
SRC_URI = " \
    git://github.com/opencontainers/runc;branch=master \
    file://0001-Remove-check-for-sym-links.patch \
    file://0001-Set-correct-permissions-to-notify-socket.patch \
"

RUNC_VERSION = "1.0.0-rc5"
