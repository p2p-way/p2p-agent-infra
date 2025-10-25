# P2P agent Ansible roles

 1. [Description](#description)
 2. [Roles](#roles)
 3. [Conisderations](#conisderations)
 4. [Run roles locally](#run-roles-locally)
 5. [Manage running agents](#manage-running-agents)


## Description

 This folder contains Ansible roles for P2P agent

| # | Role                         | Description                                    |
| - | ---------------------------- | ---------------------------------------------- |
| 1 | [common](#common-role)       | Common tasks                                   |
| 2 | [agent](#agent-role)         | Update agent script and scheduler              |
| 3 | [watcher](#watcher-role)     | Act as a watcher and configure Autoscaler      |
| 4 | [archivist](#archivist-role) | Install Archivist support - P2P (experimental) |
| 5 | [ipfs](#ipfs-role)           | Install IPFS support - P2P                     |
| 6 | [radicle](#radicle-role)     | Install Radicle support - P2P                  |
| 7 | [ton](#ton-role)             | Install TON support - P2P                      |
| 8 | [torrent](#torrent-role)     | Install Torrent support - P2P                  |

 Ansible roles are located in Git repository and agent will download and execute them. We also may update agent itself in case of need via [agent](#agent) role.

 Each P2P role will install all required software and will start downloading content distributed via P2P protocols and agent node will become a distributor.


## Roles

### Common role

 During agent configuration it may be required to perform some common tasks, like package installation, files and folders creation.


### Agent role

 Initially, agent is deployed using Terraform and at some point it may be required to add some changes to it or change its scheduler which is managed by cron.


### Watcher role

 In order to be able to manage Autoscaler settings we use [Agent side watcher](/architecture.md#agent-side-watcher).


### Archivist role

 P2P site is shared using [Archivist](https://archivist.storage). It is added in an experimental mode and does not support files metadata and name service at the moment.


### IPFS role

 P2P site is shared using [IPFS](https://en.wikipedia.org/wiki/InterPlanetary_File_System) and [Kubo](https://github.com/ipfs/kubo) supports us with that. For name service we use [ENS](https://ens.domains).


### Radicle role

 P2P agent code is shared using [Radicle](https://radicle.xyz).


### TON role

 P2P site is shared using [TON sites](https://docs.ton.org/v3/guidelines/web3/ton-proxy-sites/how-to-run-ton-site) via [TON Storage](https://docs.ton.org/v3/guidelines/web3/ton-storage/storage-daemon). For name service we use native [TON DNS](https://docs.ton.org/v3/guidelines/web3/ton-dns/dns).


### Torrent role

 Some of the site resources are spread using [BitTorrent protocol](https://en.wikipedia.org/wiki/BitTorrent). [qBittorrent](https://www.qbittorrent.org/) is an open-source client with the cross-platform support and it provides API support which is required for torrents management.


## Conisderations

 1. Roles are named by the protocols instead of the applications.
 2. Roles order matter on slow instances - gcp/e2-micro ~ 17 minutes vs ~ 24 minutes, when torrent role is located on top.
 3. By default, application installation is done only when app check is not passed - that minimise run duration up to 50-100% on slow instances, however that approach slow down initial installation.
 4. Some linting rules are not followed for readability reasons.


## Run roles locally

 In the process of development it may be required to apply roles locally on remote server and it can be done in the following way
 1. Open [required TCP/UDP ports](/terraform/generic/readme.md#deployment) on the server.

 2. [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) on remote server
    ```shell
    sudo -s

    apt update
    apt install -y curl git jq ansible python3-jmespath
    ```

 3. Copy Ansible code to the server
    ```shell
    local_dir="ansible"
    remote_dir="/opt/p2p/repository/local/ansible"
    host="ubuntu@<remote-ip>"

    rsync -avze ssh --rsync-path='sudo rsync --mkpath --exclude=ansible_all_ipv4_addresses' "${local_dir}/" "${host}:${remote_dir}/" --delete
    ```

 4. Define variables on remote server
    ```shell
    # Watcher
    export desired_capacity=1
    # Archivist
    export archivist_cid="zDvZRwzkwcFgCVMjd6VJKNSzGbNMU1HfZEcrebfmJ5NzW5C8paB3"
    # IPFS
    export ipfs_cid="bafybeicjxk7fb3btcabn36rpyooao36ixbfdw6iwy6fvksvpvuo3iyscxm"
    # Radicle
    export radicle_rid="rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5"
    # TON
    export ton_bagid="12432C1BEE1BF12FE294CB63694EFFED189B1041F4E88D51E3E65CCB2A64D8B4"
    # Torrent
    export torrent_magnet="magnet:?xt=urn:btih:c7245061816ebf134d2a9be87be600acc9b1f7c6&xt=urn:btmh:1220f759b072884c48e1c9d9e6f99aa507f982ab22e75b36aab097d198140490ed14&dn=site"
    ```

 5. Run Ansible on remote server
    ```shell
    export ANSIBLE_LOCALHOST_WARNING=false
    export ANSIBLE_INVENTORY_UNPARSED_WARNING=false
    export ANSIBLE_STDOUT_CALLBACK="debug"
    export ANSIBLE_CALLBACKS_ENABLED="profile_tasks"

    ansible-playbook /opt/p2p/repository/local/ansible/playbook.yml

    ansible-playbook /opt/p2p/repository/local/ansible/playbook.yml -e '{ apps_update: true }'
    ```


### Check

 1. **Archivist**
    ```shell
    # Service status
    systemctl status archivist

    # Lists local CIDs
    curl -s -w '\n' http://localhost:8082/api/archivist/v1/data \
      | jq -r '.content[] | .cid + " - " + (.manifest.uploadedAt| strftime("%Y-%m-%d %H:%M:%S UTC"))'
    ```

 1. **IPFS**
    ```shell
    # Service status
    systemctl status ipfs

    # Set repository location
    export IPFS_PATH="/opt/p2p/ipfs"

    # Check config
    ipfs config Addresses.AppendAnnounce

    # List pinned objects
    ipfs pin ls

    # List folder
    ipfs refs /ipfs/bafybeicjxk7fb3btcabn36rpyooao36ixbfdw6iwy6fvksvpvuo3iyscxm

    # Display object content
    ipfs cat QmUsrhmu4wXnVHejbfp9kdtb1ZrWoZ6FTCUuFczDPzP1FG
    ```

 2. **Radicle**
    ```shell
    # Service status
    systemctl status radicle

    # Set Radicle home
    export RAD_HOME=/opt/p2p/radicle

    # Check config
    rad config get node.externalAddresses

    # Check profile
    rad self

    # Check seeding repositories
    rad seed

    # Check repositories files
    find "${RAD_HOME}/storage" -maxdepth 2
    ```

 3. **TON**
    ```shell
    # Service status
    systemctl status ton-storage

    # Set TON Storage location
    TON_PATH="/opt/p2p/ton"

    # List torrents
    storage-daemon-cli -I 127.0.0.1:5555 \
      -k "${TON_PATH}/storage-db/cli-keys/client" \
      -p "${TON_PATH}/storage-db/cli-keys/server.pub" \
      -c "list --hashes"

    # List files
    find "${TON_PATH}/storage-db/torrent/torrent-files"
    ```

 4. **Torrent**
    ```shell
    # Service status
    systemctl status qbittorrent

    # List torrents
    curl -s http://localhost:8081/api/v2/torrents/info | jq -r '.[] | .state + " - " + .magnet_uri'

    # List files
    find /opt/p2p/torrent/Downloads

    # UI
    Host: <Public IP>:8081
    Username: awk -F '=' '/Username/ {print $2 }' /opt/p2p/torrent/.config/qBittorrent/qBittorrent.conf
    Password: adminadmin
    ```


## Manage running agents

 Agents are managed by defined [roles](#roles) and we can update their configuration when required.


### Common

 Besides the variables in [*playbook.yml*](playbook.yml), all P2P roles has some common variables which defines how installation process will go
 - `<app>_enabled` - defines if app is enabled and can be used to disable and stop it after it was already installed
 - `<app>_update` - defines if installation process should be forced, even if app is installed, running and ready

 Variable `apps_update` - in [*playbook.yml*](playbook.yml), overrides `<app>_update` for all P2P roles.


### Update agent

 We can update agent via [Agent role](#agent-role) and to peform this task we should
 1. Update [*roles/agent/files/p2p-agent.sh*](roles/agent/files/p2p-agent.sh) file if required.
 2. Update `agent_file` and `cron_minute` variables and then set `update_agent` or `update_agent` variables to `true` in [*playbook.yml*](playbook.yml).


### Update watcher

 We can update watcher via [Watcher role](#watcher-role) and to peform this task we should
 1. Update `desired_capacity` in [*playbook.yml*](playbook.yml)
    ```yaml
    # No changes
    desired_capacity: ''

    # Run 3 nodes in all Clouds and regions
    desired_capacity: 3
    desired_capacity: '{"all": 3}'

    # AWS only - 2 nodes in all regions and 3 nodes in eu-central-1 one
    desired_capacity: '{"aws": {"all": 2, "eu-central-1": 3}}'

    # Clouds and selected regions
    desired_capacity: '{"all": "-", "aliyun": {"all": 2, "eu-central-1": 3}, "aws": {"all": 2, "eu-central-1": 3}, "azure": {"all": 2, "GermanyWestCentral": 3}, "gce": {"all": 2, "europe-central2": 3}}'
    ```


### Update Archivist CID

 We can update Archivist CID via [Archivist role](#archivist-role) and to peform this task we should
 1. Update `archivist_cid` in [*playbook.yml*](playbook.yml).


### Update IPFS CID

 We can update IPFS CID via [IPFS role](#ipfs-role) and to peform this task we should
 1. Update `ipfs_cid` in [*playbook.yml*](playbook.yml).


### Update Radicle RID

 We can update Radicle RID via [Radicle role](#radicle-role) and to peform this task we should
 1. Update `radicle_rid` in [*playbook.yml*](playbook.yml).


### Update TON BagID

 We can update TON BagID via [TON role](#ton-role) and to peform this task we should
 1. Update `ton_bagid` in [*playbook.yml*](playbook.yml).


### Update Torrent magnet

 We can update Torrent magnet via [Torrent role](#torrent-role) and to peform this task we should
 1. Update `torrent_magnet` in [*playbook.yml*](playbook.yml).

> [!NOTE]
> Variables `archivist_cid`, `ipfs_cid`, `radicle_rid`, `ton_bagid` and `torrent_magnet` accept multiple, space delimited values.
