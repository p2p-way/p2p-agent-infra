#!/bin/bash

# Repository SSH private key

# Variables
export HOME=~
ssh_private_key="${ssh_private_key}"
ssh_private_key_file="$${HOME}/.ssh/$(base64 -d <<< $${ssh_private_key} | ssh-keygen -yf /dev/stdin | ssh-keygen -lf - | awk -F '[()]' '{print "id_" tolower($2)}')"

# SSH
base64 -d <<< "$${ssh_private_key}" > "$${ssh_private_key_file}"
chmod 600 "$${ssh_private_key_file}"

# Git
git config --global core.sshCommand 'ssh -o StrictHostKeyChecking=accept-new'
