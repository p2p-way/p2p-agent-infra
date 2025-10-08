#!/bin/bash

# CloudMonitor Agent init

# Install
# https://help.aliyun.com/zh/cms/user-guide/release-notes
export ARGUS_VERSION=3.5.12
curl -s https://cms-agent-${region}.oss-${region}-internal.aliyuncs.com/Argus/agent_install-1.13.sh | bash

# Service
# systemctl restart cloudmonitor
