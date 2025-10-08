#!/bin/bash

# Netplan init

# Variables
BASE_FOLDER="${base_folder}"
config="$${BASE_FOLDER}/netplan*.yaml"
interface_name=$(ip -o -4 route show to default | awk '{print $5}')

# Update
sed -i "s/interface-name/$${interface_name}/" ""$${config}""

# Move
mv ""$${config}"" /etc/netplan

# Apply
netplan apply
