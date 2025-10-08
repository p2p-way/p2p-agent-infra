#!/bin/bash

# Ops Agent init

# Variables
BASE_FOLDER="${base_folder}"

# Get
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh

# Install
bash add-google-cloud-ops-agent-repo.sh --also-install

# Config
cat "$${BASE_FOLDER}"/ops-agent-*.yaml > /etc/google-cloud-ops-agent/config.yaml
rm -f "$${BASE_FOLDER}"/ops-agent-*.yaml
systemctl restart google-cloud-ops-agent
