HAWKBIT_CONFIG_FILE ?= "${TMPDIR}/config.cfg"

python __anonymous() {
    import configparser
    import os
    config_file = d.getVar('HAWKBIT_CONFIG_FILE')
    if os.path.isfile(config_file):
        config = configparser.ConfigParser()
        config.read(config_file)
        d.setVar('OSTREE_BRANCHNAME', config['ostree']['ostree_name_remote'])
        d.setVar('OSTREE_OSNAME', config['ostree']['ostree_name_remote'])
        d.setVar('HAWKBIT_HOSTNAME', 'hawkbit')
        d.setVar('OSTREE_HOSTNAME', 'ostree')
        d.setVar('OSTREE_SSHPORT', '22')
    else:
        bb.fatal('Cannot open {}', config_file)
}
