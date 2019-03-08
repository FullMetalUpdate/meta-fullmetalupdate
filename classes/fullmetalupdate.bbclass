python __anonymous() {
    import configparser
    import os

    ostree_repo = d.getVar('OSTREE_REPO')
    if not ostree_repo:
        bb.fatal("OSTREE_REPO should be set in your local.conf")

    config_file = d.getVar('HAWKBIT_CONFIG_FILE')
    if not config_file:
        bb.fatal("Please export/define HAWKBIT_CONFIG_FILE")

    if not os.path.isfile(config_file):
        bb.fatal("HAWKBIT_CONFIG_FILE(" + config_file + ") is not a file, please fix the path" , config_file)

    config = configparser.ConfigParser()
    config.read(config_file)

    server_host_name = config['server']['server_host_name']
    hawkbit_vendor_name = config['client']['hawkbit_vendor_name']
    hawkbit_url_port = config['client']['hawkbit_url_port']
    hawkbit_ssl = config['client'].getboolean('hawkbit_ssl', fallback=False)
    ostree_name_remote = config['ostree']['ostree_name_remote']
    ostree_gpg_verify = config['ostree'].getboolean('ostree_gpg-verify', fallback=False)
    ostree_ssl = config['ostree'].getboolean('ostree_ssl', fallback=False)
    ostree_url_port = config['ostree']['ostree_url_port']
    ostreepush_ssh_port = config['ostree']['ostreepush_ssh_port']
    ostreepush_ssh_user = config['ostree']['ostreepush_ssh_user']
    ostreepush_ssh_pwd = config['ostree']['ostreepush_ssh_pwd']
    hawkbit_hostname = "hawkbit"
    ostree_hostname = "ostree"

    if ostree_ssl:
        ostree_http_address = "https://" + ostree_hostname + ":" + ostree_url_port
    else:
        ostree_http_address = "http://" + ostree_hostname + ":" + ostree_url_port

    if hawkbit_ssl:
        hawkbit_http_address = "https://" + hawkbit_hostname + ":" + hawkbit_url_port
    else:
        hawkbit_http_address = "http://" + hawkbit_hostname + ":" + hawkbit_url_port

    ostree_http_distant_address =  server_host_name + ".local:" + ostree_url_port
    ostree_ssh_address = "ssh://" + ostreepush_ssh_user + "@" + ostree_hostname + ":" + ostreepush_ssh_port + "/ostree/repo"

    d.setVar('HAWKBIT_VENDOR_NAME', hawkbit_vendor_name)
    d.setVar('HAWKBIT_URL_PORT', hawkbit_url_port)
    d.setVar('HAWKBIT_SSL', hawkbit_ssl)
    d.setVar('OSTREE_BRANCHNAME', ostree_name_remote)
    d.setVar('OSTREE_OSNAME', ostree_name_remote)
    d.setVar('HAWKBIT_HOSTNAME', hawkbit_hostname)
    d.setVar('OSTREE_HOSTNAME', ostree_hostname)
    d.setVar('OSTREE_URL_PORT', ostree_url_port)
    d.setVar('OSTREEPUSH_SSH_PORT', ostreepush_ssh_port)
    d.setVar('OSTREEPUSH_SSH_USER', ostreepush_ssh_user)
    d.setVar('OSTREEPUSH_SSH_PWD', ostreepush_ssh_pwd)
    d.setVar('OSTREE_HTTP_ADDRESS', ostree_http_address)
    d.setVar('OSTREE_HTTP_DISTANT_ADDRESS', ostree_http_distant_address)
    d.setVar('OSTREE_SSH_ADDRESS', ostree_ssh_address)
    d.setVar('HAWKBIT_HTTP_ADDRESS', hawkbit_http_address)
}

ostree_init() {
    local OSTREE_REPO="$1"
    local OSTREE_REPO_MODE="$2"

    ostree --repo=${OSTREE_REPO} init --mode=${OSTREE_REPO_MODE}
}

ostree_push() {
    local OSTREE_REPO="$1"
    local OSTREE_BRANCH="$2"

    bbnote "Push the build result to the remote OSTREE"
    sshpass -p ${OSTREEPUSH_SSH_PWD} ostree-push --repo ${OSTREE_REPO} ${OSTREE_SSH_ADDRESS} ${OSTREE_BRANCH}
}

ostree_pull() {
    local OSTREE_REPO="$1"
    local OSTREE_BRANCH="$2"

    ostree pull ${OSTREE_BRANCH} ${OSTREE_BRANCH} --depth=-1 --mirror --repo=${OSTREE_REPO}
}

ostree_revparse() {
    local OSTREE_REPO="$1"
    local OSTREE_BRANCH="$2"

    ostree rev-parse ${OSTREE_BRANCH} --repo=${OSTREE_REPO} | head
}

ostree_remote_add() {
    local OSTREE_REPO="$1"
    local OSTREE_BRANCH="$2"
    local OSTREE_HTTP_ADDRESS="$3"

    ostree remote add --no-gpg-verify ${OSTREE_BRANCH} ${OSTREE_HTTP_ADDRESS} --repo=${OSTREE_REPO}
}

ostree_remote_delete() {
    local OSTREE_REPO="$1"
    local OSTREE_BRANCH="$2"

    ostree remote delete ${OSTREE_BRANCH} --repo=${OSTREE_REPO}
}
