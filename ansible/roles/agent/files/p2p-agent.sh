#!/bin/bash

# P2P agent

# Variables
BASE_FOLDER="/opt/p2p"
LOCAL_FOLDER="repository"
LOG_FILE=$(dirname "${BASE_FOLDER}")/p2p-agent.log
RADICLE_ALIAS=$(xxd -l5 -ps /dev/urandom)
WAIT=$((1 + ${RANDOM} % 10))

# Commands
ENABLE_CC="true"
ENABLE_POST_RUN="true"
ENABLE_PRE_RUN="true"

# Commands defaults
DEFAULT_DELAY=60
DEFAULT_FORCE_RUN="true"
DEFAULT_MAIN_RUN="ansible/playbook.yml"
DEFAULT_POST_RUN='echo "Finish: $(date)"'
DEFAULT_PRE_RUN='echo "Start: $(date)"'
DEFAULT_REPOSITORY="https://github.com/p2p-way/p2p-agent-infra"
DEFAULT_REPOSITORY_MODE="client-server"
DEFAULT_REPOSITORY_RADICLE="rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5"
DEFAULT_TYPE="ansible"

# Control center
CC_HOSTS=(
https://d2d0z7lax5amc3.cloudfront.net
)
CC_COMMANDS="delay desired-capacity force-run main-run post-run pre-run repository type"
CC_COMMANDS_PREFIX="cc-a"


# Log
log() {
  [[ "${1}" == *"run_start -"* ]] && echo -e "####################" >> "${LOG_FILE}"
  echo -e "$(date) - $$ - $1"
  echo -e "$(date) - $$ - $1" >> "${LOG_FILE}"
  [[ "${1}" == *"run_finish -"* ]] && echo -e "####################\n\n" >> "${LOG_FILE}"
}

# Start
run_start() {
  # Log
  log "${FUNCNAME[0]} - Task started"
}

# Stop precedent execution
stop_precedent() {
  # Log
  log "${FUNCNAME[0]} - Stop precedent execution if running"

  # Stop
  pgid_current=$(ps -o pgid= $$ | tr -d ' ')
  for pid in $(pgrep -f "$0"); do
    pgid=$(ps -o pgid= "${pid}" | tr -d ' ')
    if [[ -n "${pgid}" && "${pgid}" != "${pgid_current}" ]]; then
      log "${FUNCNAME[0]} - Kill pgid ${pgid}"
      kill -9 -"${pgid}"
    else
      log "${FUNCNAME[0]} - No precedent execution found"
    fi
  done
}

# Compute repository mode
compute_repository_mode() {
  if [[ "${DEFAULT_REPOSITORY_MODE}" == "radicle" && -n "${DEFAULT_REPOSITORY_RADICLE}" ]]; then
    repository_mode="radicle"
    DEFAULT_REPOSITORY="${DEFAULT_REPOSITORY_RADICLE}"
  else
    repository_mode="client-server"
  fi
  log "${FUNCNAME[0]} - Repository mode: ${repository_mode}"
}

# Contact control center
contact_cc() {
  if [[ "${repository_mode}" == "client-server" ]]; then
    if [[ "${ENABLE_CC}" == "true" ]]; then
      # Log
      log "${FUNCNAME[0]} - Contact control center"
      log "${FUNCNAME[0]} - ${CC_HOSTS[*]}"

      # Wait
      log "${FUNCNAME[0]} - Wait ${WAIT} seconds"
      sleep "${WAIT}"

      # Get data from CC
      for url in "${CC_HOSTS[@]}"; do
        log "${FUNCNAME[0]} - Control center: ${url}"
        commands_cc=$(curl -m 10 -s -I "${url}" | grep "${CC_COMMANDS_PREFIX}")
        [[ "${commands_cc}" == *"${CC_COMMANDS_PREFIX}"* ]] && { log "${FUNCNAME[0]} - Commands received"; break; }
      done
      while read -r command; do
        log "${FUNCNAME[0]} - Command: ${command}"
      done <<< "${commands_cc}"
    else
      # Log
      log "${FUNCNAME[0]} - Control center is disabled, use defaults"
    fi
  else
    # Log
    log "${FUNCNAME[0]} - Control center is disabled because repository mode is ${repository_mode}"
  fi
}

# Set variables
set_variables() {
  # Log
  log "${FUNCNAME[0]} - Set variables"

  # Set values from CC and failback to defaults
  for command in ${CC_COMMANDS}; do
    # Command value from CC
    value_cc=$(sed -n "s/^${CC_COMMANDS_PREFIX}-${command}: //p" <<< "${commands_cc}" | tr -d '\r')

    # Transform command name
    command="${command//-/_}"

    # Compute name of the variable with default value
    value_default=$(awk '{print toupper($0)}' <<< "default_${command}" | tr -d '\r')

    # Use default value if not set from CC
    if [[ -z "${value_cc}" || "${value_cc}" == '""' || "${value_cc}" == "''" || "${value_cc}" == "-" ]]; then
      declare value="${!value_default}"
    else
      value="${value_cc}"
    fi

    # Set command value
    export "${command}"="${value}"

    # Log
    if [[ "${ENABLE_CC}" == "true" && "${repository_mode}" == "client-server" ]]; then
      log "${FUNCNAME[0]} - ${command}: CC value = '${value_cc}'"
      log "${FUNCNAME[0]} - ${command}: Default value = '${!value_default}'"
    fi
    log "${FUNCNAME[0]} - ${command}: '${value}'"
  done
}

# Install Radicle
install_radicle() {
  # Check if Radicle is installed
  if ! (which rad > /dev/null 2>&1); then
    # Log
    log "${FUNCNAME[0]} - Radicle binary not found, try to install"

    # Log
    log "${FUNCNAME[0]} - Install Radicle"

    # Wait
    log "${FUNCNAME[0]} - Wait ${WAIT} seconds"
    sleep "${WAIT}"

    # Install
    WAIT=300
    SECONDS=0
    while (( SECONDS < WAIT )); do
      if (curl -m 30 -sSf https://radicle.xyz/install | sh -s -- --prefix=/usr/local); then break; fi
      sleep 5
    done

    # Status and key pair
    if (which rad > /dev/null 2>&1); then
      # Log
      log "${FUNCNAME[0]} - Radicle installed successfully"

      # Create key pair
      log "${FUNCNAME[0]} - Create Radicle key pair"
      if (echo | rad auth --alias "${RADICLE_ALIAS}" --stdin > /dev/null 2>&1); then
        # Log
        log "${FUNCNAME[0]} - Radicle key pair created successfully"
      else
        # Log
        log "${FUNCNAME[0]} - Radicle key pair creation failed"

        # Exit
        run_finish
      fi
    else
      # Log
      log "${FUNCNAME[0]} - Radicle installation failed"

      # Exit
      run_finish
    fi
  fi
}

# Radicle node
radicle_node() {
  # Check service
  radicle_service_file=$(grep -rl 'RAD_HOME.*' /usr/lib/systemd/system)
  [[ -z "${radicle_service_file}" ]] && radicle_service_file=/dev/null
  RAD_HOME=$(awk -F 'RAD_HOME=| ' '/RAD_HOME/ {print $2}' "${radicle_service_file}")
  if [[ -n "${RAD_HOME}" ]]; then
    # Vaiables
    export RAD_HOME="${RAD_HOME//\"/}"
    radicle_service_name=$(basename "${radicle_service_file}")
    radicle_is_service="true"
    radicle_user=$(awk -F 'User=' '/User/ {print $2}' "${radicle_service_file}")

    # Log
    log "${FUNCNAME[0]} - Radicle node is running as service"
  else
    unset RAD_HOME
  fi

  # Check node status
  radicle_node_status=$(rad node status | grep -i "Node is")

  # Start Radicle service
  if [[ "${radicle_is_service}" == "true" && "${radicle_node_status}" == *"Node is stopped"* ]]; then
    # Log
    log "${FUNCNAME[0]} - Radicle node status: ${radicle_node_status}"
    log "${FUNCNAME[0]} - Start Radicle service"

    # Start
    if (systemctl start "${radicle_service_name}"); then
      # Log
      log "${FUNCNAME[0]} - Radicle service successfully started"

      # Wait
      log "${FUNCNAME[0]} - Wait after Radicle start"
      sleep 10
    else
      # Log
      log "${FUNCNAME[0]} - Radicle service failed to start"

      # Exit
      run_finish
    fi
  fi

  # Start Radicle node
  if [[ "${radicle_is_service}" != "true" && "${radicle_node_status}" == *"Node is stopped"* ]]; then
    # Log
    log "${FUNCNAME[0]} - Radicle node status: ${radicle_node_status}"
    log "${FUNCNAME[0]} - Start Radicle node"

    # Start
    if (rad node start); then
      # Log
      log "${FUNCNAME[0]} - Radicle node successfully started"

      # Wait
      log "${FUNCNAME[0]} - Wait after Radicle start"
      sleep 10
    else
      # Log
      log "${FUNCNAME[0]} - Radicle node failed to start"

      # Exit
      run_finish
    fi
  fi
}

# Get repository
get_repository() {
  # Log
  log "${FUNCNAME[0]} - Get repository: repository mode is ${repository_mode}"

  # Variables
  repository_updated="false"
  origin="origin"
  head="HEAD"

  # Create base_folder if not exist
  [[ -d "${BASE_FOLDER}" ]] || mkdir -p "${BASE_FOLDER}"

  # Create repository_base_folder  if not exist
  [[ -d "${repository_base_folder}" ]] || mkdir -p "${repository_base_folder}"

  # Set proper permissions
  [[ "$(stat -c "%a" "${repository_base_folder}")" != *"777"* ]] && chmod 777 "${repository_base_folder}"

  # Radicle
  if [[ "${repository_mode}" == "radicle" ]]; then
    # Variables
    origin="rad"
    head="heads"

    # Install Radicle
    install_radicle

    # Check Radicle node
    radicle_node

    # Adjust repository folder when initial sync
    [[ "${radicle_is_service}" != "true" ]] && repository_folder="${repository_folder}-initial"
  fi

  # Check if repository was already cloned
  if (git -C "${repository_folder}" branch > /dev/null 2>&1); then
    # Log
    log "${FUNCNAME[0]} - Repository was alredy cloned to ${repository_folder}"

    # Get local commit sha
    if [[ "${radicle_is_service}" == "true" ]]; then
      local_sha=$(sudo -u "${radicle_user}" bash -c "export RAD_HOME=""${RAD_HOME}""; git -C ""${repository_folder}"" rev-parse HEAD")
    else
      local_sha=$(git -C "${repository_folder}" rev-parse HEAD)
    fi

    # Radicle
    if [[ "${repository_mode}" == "radicle" ]]; then
      # Log
      log "${FUNCNAME[0]} - Sync Radicle repository"

      # Sync repository
      cd "${repository_folder}" || exit
      if [[ "${radicle_is_service}" == "true" ]]; then
        sudo -u "${radicle_user}" bash -c "export RAD_HOME=""${RAD_HOME}""; rad sync ""${repository}"" --timeout 30"
      else
        rad sync "${repository}" --timeout 30
      fi

      cd ..
    fi

    # Get remote commit sha
    if [[ "${radicle_is_service}" == "true" ]]; then
      remote_sha=$(sudo -u "${radicle_user}" bash -c "export RAD_HOME=""${RAD_HOME}""; git -C ""${repository_folder}"" ls-remote ""${origin}""" | awk '/'${head}'/ && !/'${head}'\/patches/ {print $1}')
    else
      remote_sha=$(git -C "${repository_folder}" ls-remote "${origin}" | awk '/'${head}'/ && !/'${head}'\/patches/ {print $1}')
    fi

    # Log
    log "${FUNCNAME[0]} - Local commit: ${local_sha}"
    log "${FUNCNAME[0]} - Remote commit: ${remote_sha}"

    # Check if local repository is up to date
    if [[ "${local_sha}" != "${remote_sha}" || "${force_run}" == "true" ]]; then
      # Log
      log "${FUNCNAME[0]} - Update repository ${repository_folder} (force_run = ${force_run})"

      # Get latest updates
      if [[ "${radicle_is_service}" == "true" ]]; then
        sudo -u "${radicle_user}" bash -c "export RAD_HOME=""${RAD_HOME}""; git -C ""${repository_folder}"" pull --rebase"
      else
        # Wait
        log "${FUNCNAME[0]} - Wait ${WAIT} seconds"
        sleep "${WAIT}"

        git -C "${repository_folder}" pull --rebase
      fi

      # Log
      log "${FUNCNAME[0]} - Repository ${repository_folder} was updated (force_run = ${force_run})"

      # Notify about repository changes
      repository_updated="true"
    else
      # Log
      log "${FUNCNAME[0]} - Repository ${repository_folder} is up to date"
    fi
  # Clone repository
  else
    # Log
    log "${FUNCNAME[0]} - Clone ${repository_mode} ${repository} repository to ${repository_folder}"

    # Radicle
    if [[ "${repository_mode}" == "radicle" ]]; then
      if [[ "${radicle_is_service}" == "true" ]]; then
        if (sudo -u "${radicle_user}" bash -c "export RAD_HOME=""${RAD_HOME}""; rad clone ""${repository}"" ""${repository_folder}"" --timeout 60"); then cloned_successfully=true; fi
      else
        if (rad clone "${repository}" "${repository_folder}" --timeout 60); then cloned_successfully=true; fi
      fi
    # Client-Server
    else
      # Wait
      log "${FUNCNAME[0]} - Wait ${WAIT} seconds"
      sleep "${WAIT}"

      if (git clone "${repository}" "${repository_folder}"); then cloned_successfully=true; fi
    fi

    # Clone status
    if [[ "${cloned_successfully}" == "true" ]]; then
      # Log
      log "${FUNCNAME[0]} - Repository successfully cloned to ${repository_folder}"

      # Mark repository folder as safe
      if [[ "${radicle_is_service}" == "true" ]]; then git config --global --add safe.directory "${repository_folder}"; fi

      # Notify about repository changes
      repository_updated="true"
    else
      # Log
      log "${FUNCNAME[0]} - Failed to clone repository to ${repository_folder}"
    fi

    # Exit
    [[ "${cloned_successfully}" != "true" ]] && run_finish
  fi
}

# Execute pre-run
exec_pre_run() {
  if [[ "${ENABLE_PRE_RUN}" == "true" ]]; then
    # Log
    log "${FUNCNAME[0]} - Execute pre-run: ${pre_run}"

    # Execute
    bash -c "${pre_run}"
  else
    # Log
    log "${FUNCNAME[0]} - Execution of pre-run is disabled"
  fi
}

# Execute main-run
exec_main_run() {
  # Variables
  repository_folder=$(sed -e 's|//||' -e 's|[@:./]|-|g' <<< "${repository}")
  repository_base_folder="${BASE_FOLDER}/${LOCAL_FOLDER}"
  repository_folder="${repository_base_folder}/${repository_folder}"
  export ANSIBLE_LOG_PATH="${LOG_FILE}"
  export ANSIBLE_STDOUT_CALLBACK="debug"
  export ANSIBLE_CALLBACKS_ENABLED="profile_tasks"
  export ANSIBLE_LOCALHOST_WARNING=false
  export ANSIBLE_INVENTORY_UNPARSED_WARNING=false

  # Log
  log "${FUNCNAME[0]} - Execute main-run: ${type}"

  # Execute - Ansible
  if [[ "${type}" == "ansible" ]]; then
    # Radicle
    if [[ "${repository_mode}" == "radicle" ]]; then
      # Get repository
      get_repository

      # Execute Ansible if repository was updated
      if [[ "${repository_updated}" == "true" ]]; then
        # Log
        log "${FUNCNAME[0]} - Repository was updated, run Ansible"

        # Run Ansible
        ansible-playbook "${repository_folder}/${main_run}"
      else
        # Log
        log "${FUNCNAME[0]} - No repository changes, skip execution"
      fi

    elif [[ "${repository_mode}" == "client-server" ]]; then
      # Log
      log "${FUNCNAME[0]} - Run Ansible pull"

      # Run Ansible pull
      [[ "${force_run}" == "false" ]] && ansible_pull_args="--only-if-changed"
      ansible-pull \
        ${ansible_pull_args} \
        --accept-host-key \
        --url "${repository}" \
        --directory "${repository_folder}" \
        --clean \
        --sleep "${delay}" \
        "${repository_folder}/${main_run}"
    else
      # Log
      log "${FUNCNAME[0]} - Repository ${repository_mode} is undefined"

      # Exit
      run_finish
    fi

  # Execute - Shell
  elif [[ "${type}" == "shell" ]]; then
    # Get repository
    get_repository

    # Execute shell script if repository was updated
    if [[ "${repository_updated}" == "true" ]]; then
      # Log
      log "${FUNCNAME[0]} - Repository was updated, run shell script"

      # Execute
      bash "${repository_folder}/${main_run}"
    else
      # Log
      log "${FUNCNAME[0]} - No repository changes, skip execution"
    fi

  else
    # Log
    log "${FUNCNAME[0]} - Type ${type} is undefined"
  fi
}

# Execute post-run
exec_post_run() {
  if [[ "${ENABLE_POST_RUN}" == "true" ]]; then
    # Log
    log "${FUNCNAME[0]} - Execute post-run: ${post_run}"

    # Execute
    bash -c "${post_run}"
  else
    # Log
    log "${FUNCNAME[0]} - Execution of post-run is disabled"
  fi
}

# Finish
run_finish() {
  # Log
  log "${FUNCNAME[0]} - Task finished"

  # Exit
  exit
}


# Run
run_start
stop_precedent
compute_repository_mode
contact_cc
set_variables
exec_pre_run
exec_main_run
exec_post_run
run_finish
