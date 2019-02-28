#! /bin/sh
export QT_QPA_PLATFORM=eglfs
export QT_EGLFS_IMX6_NO_FB_MULTI_BUFFER=1

# Avoids tearing issues on the screen
export FB_MULTI_BUFFER=3

# i.MX6 SDP physical screen size in mm
export QT_QPA_EGLFS_PHYSICAL_WIDTH=200
export QT_QPA_EGLFS_PHYSICAL_HEIGHT=150

/usr/bin/python3 /bin/fullmetalupdate/fullmetalupdate.py --config /bin/fullmetalupdate/rauc_hawkbit/config.cfg
