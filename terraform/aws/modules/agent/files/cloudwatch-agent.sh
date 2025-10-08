#!/bin/bash

# CloudWatch Agent init

# Variables
BASE_FOLDER="${base_folder}"

# Get
arch=$([[ `uname -i` == "x86_64" ]] && echo amd64 || echo arm64)
curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/$${arch}/latest/amazon-cloudwatch-agent.deb

# Install
dpkg -i -E amazon-cloudwatch-agent.deb
rm -f amazon-cloudwatch-agent.deb

# Config
mv "$${BASE_FOLDER}"/cloudwatch-*.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d

# Service
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent
