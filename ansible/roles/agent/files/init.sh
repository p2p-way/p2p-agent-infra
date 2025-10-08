#!/bin/bash

# P2P agent init

# Install apps
WAIT=600
SECONDS=0
while (( SECONDS < WAIT )); do
  apt update
  if (apt install -y curl git jq ansible python3-jmespath); then break; fi
  sleep 5
done

# Get Cloud
cloud=$(cloud-init query cloud-name || true)

# Mark instance as unhealth if Ansible was not installed
if [[ -z "$(which ansible-pull)" ]]; then
  case "${cloud}" in
    akamai) halt -p                                       ;;
    aliyun) halt -p                                       ;;
    aws)    halt -p                                       ;;
    azure)  systemctl disable ssh; systemctl stop ssh     ;;
    gce)    systemctl disable ssh; systemctl stop ssh     ;;
    *)      echo "Error - ansible-pull was not installed" ;;
  esac
fi

# Cron
task="task.cron"
echo "#Ansible: P2P agent" > "${task}"
echo "*/15 * * * * bash /opt/p2p-agent.sh" >> "${task}"
crontab "${task}"
rm -f "${task}"
