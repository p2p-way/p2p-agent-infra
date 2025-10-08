#!/bin/bash

# Logtail Agent init

# Get the script
curl -O http://logtail-release-${region}.oss-${region}.aliyuncs.com/linux64/logtail.sh

# Install
chmod +x logtail.sh; ./logtail.sh install ${region}-acceleration

# Configs
echo "${user_defined_id}" > /etc/ilogtail/user_defined_id

# Service
systemctl restart ilogtaild
