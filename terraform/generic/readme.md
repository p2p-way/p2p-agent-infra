# P2P agent on generic installation

 1. [Description](#description)
 2. [Deployment](#deployment)


## Description

 In some cases it maybe required to deploy P2P agent in a generic way in the Cloud, VM or using bare metall. This is a brief guide how it can be done.


## Deployment

 1. Run a node with Ubuntu.

 2. Open the following ports
    | App       | Ports           |
    | --------- | --------------- |
    | Archivist | `TCP/UDP: 8090` |
    | IPFS      | `TCP/UDP: 4001` |
    | Radicle   | `TCP: 8776`     |
    | TON       | `UDP: 3333`     |
    | Torrent   | `TCP/UDP: 2345` |

 3. Get Ansible code from GitHub repository
    ```shell
    git clone https://github.com/p2p-way/p2p-agent-infra
    ```

 4. If repository is private and can be accessed via SSH, we should add a private key to the instance and public key should be added on repository side
    ```shell
    # Private key
    ssh-keygen -t ed25519 -f "${HOME}/.ssh/id_ed25519" -N "" -C p2p-agent

    # Public key
    cat "${HOME}/.ssh/id_ed25519.pub"
    ```

 5. Copy agent script
    ```shell
    cp p2p-agent-infra/ansible/roles/agent/files/p2p-agent.sh /opt
    ```

    [Agent side watcher](../../architecture.md#agent-side-watcher) will not work, but we still can adjust some configuration by editing script variables. Please see [Configuration](../readme.md#configuration) and [Deployment scenarios](../readme.md#deployment-scenarios) for more information.

 6. Install required software and add agent to the cron
    ```shell
    bash p2p-agent-infra/ansible/roles/agent/files/init.sh
    ```

 After all the steps execution we will have all required software installed and P2P agent script will be triggered by the cron task.
