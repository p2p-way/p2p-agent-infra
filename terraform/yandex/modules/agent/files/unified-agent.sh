#!/bin/bash

# Unified Agent init

# Variables
BASE_FOLDER="${base_folder}"

# Get
os_file="/etc/os-release"
os_arch=$([[ `uname -i` == "x86_64" ]] && echo amd64 || echo arm64)
os_name=$(awk -F'"' '/^NAME/ {print tolower($2)}' "$${os_file}")
os_version=$(awk -F'"' '/^VERSION_ID/ {print $2}' "$${os_file}")
os_codename=$(awk -F'=' '/^VERSION_CODENAME/ {print $2}' "$${os_file}")
os_full_name="$${os_name}-$${os_version}-$${os_codename}"
ua_version=$(curl --silent https://storage.yandexcloud.net/yc-unified-agent/latest-version)
ua_file="yandex-unified-agent_$${ua_version}_$${os_arch}.deb"

curl \
  --silent \
  --remote-name \
  "https://storage.yandexcloud.net/yc-unified-agent/releases/$${ua_version}/deb/$${os_full_name}/$${ua_file}"

# Install
sudo dpkg -i "$${ua_file}"

# Config
mv "$${BASE_FOLDER}"/unified-agent-*.yml /etc/yandex/unified_agent/conf.d
rm -f "$${BASE_FOLDER}"/unified-agent-*.yml
systemctl restart unified-agent
