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
    local ostree_repo="$1"
    local ostree_repo_mode="$2"

    ostree --repo=${ostree_repo} init --mode=${ostree_repo_mode}
}

ostree_init_if_non_existent() {
    local ostree_repo="$1"
    local ostree_repo_mode="$2"

    if [ ! -d ${ostree_repo} ]; then
        ostree_init ${ostree_repo} ${ostree_repo_mode}
    fi
}

ostree_push() {
    local ostree_repo="$1"
    local ostree_branch="$2"

    bbnote "Push the build result to the remote OSTREE"
    sshpass -p ${OSTREEPUSH_SSH_PWD} ostree-push --repo ${ostree_repo} ${OSTREE_SSH_ADDRESS} ${ostree_branch}
}

ostree_pull() {
    local ostree_repo="$1"
    local ostree_branch="$2"

    ostree pull ${ostree_branch} ${ostree_branch} --depth=-1 --mirror --repo=${ostree_repo}
}

ostree_revparse() {
    local ostree_repo="$1"
    local ostree_branch="$2"

    ostree rev-parse ${ostree_branch} --repo=${ostree_repo} | head
}

ostree_remote_add() {
    local ostree_repo="$1"
    local ostree_branch="$2"
    local ostree_http_address="$3"

    ostree remote add --no-gpg-verify ${ostree_branch} ${ostree_http_address} --repo=${ostree_repo}
}

ostree_remote_delete() {
    local ostree_repo="$1"
    local ostree_branch="$2"

    ostree remote delete ${ostree_branch} --repo=${ostree_repo}
}

ostree_is_remote_present() {
    local ostree_repo="$1"
    local ostree_branch="$2"

    ostree remote list --repo=${ostree_repo} | grep -q ${ostree_branch}
}

ostree_remote_add_if_not_present() {
    local ostree_repo="$1"
    local ostree_branch="$2"
    local ostree_http_address="$3"

    if ! ostree_is_remote_present ${ostree_repo} ${ostree_branch}; then
        ostree_remote_add ${ostree_repo} ${ostree_branch} ${ostree_http_address}
    fi
}

curl_post() {
    local hawkbit_rest="$1"
    local hawkbit_data="$2"

    curl "${HAWKBIT_HTTP_ADDRESS}/rest/v1/softwaremodules/${hawkbit_rest}" -i -X POST --user admin:admin -H "Content-Type: application/hal+json;charset=UTF-8" -d "${hawkbit_data}"
}

hawkbit_metadata_value() {
    local key="$1"
    local value="$2"

    echo '[ { "targetVisible" : true, "value" : "'${value}'", "key" : "'${key}'" } ]'
}
