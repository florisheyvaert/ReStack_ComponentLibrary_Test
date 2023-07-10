#!/bin/bash

# Parameters
VM_CT_ID="$1"                
PBS_STORAGE="$2"             
PROXMOX_HOST="$3"  
SSH_PRIVATE_KEY="$4"

# Vars
messages=()          

# Functions
echo_message() {
    local message="$1"
    local error="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

    echo '{
        "timestamp": "'"$timestamp"'",
        "componentName": "'"$componentname"'",
        "message": "'"$message"'",
        "error": '$error'
    }'
}

end_script(){
    local status="$1"

    echo '['
    for ((i=0; i<${#messages[@]}; i++)); do
        echo "${messages[i]}"
        if [[ $i -lt $(( ${#messages[@]} - 1 )) ]]; then
            echo ","
        fi
    done
    echo ']'

    exit $status
}

# Run
if [[ -z $VM_CT_ID ]]; then
    messages+=("$(echo_message -e "Please provide the VM or CT ID." true)")
    end_script 1
fi

if [[ -z $PBS_STORAGE ]]; then
    messages+=("$(echo_message -e "Please specify the PBS storage name." true)")
    end_script 1
fi

if [[ -z $SSH_PRIVATE_KEY ]]; then
    messages+=("$(echo_message -e "Please provide the SSH private key file name.${NC}" true)")
    end_script 1
fi

if [[ -z $PROXMOX_HOST ]]; then
    messages+=("$(echo_message -e "Please specify the Proxmox host IP address or hostname." true)")
    end_script 1
fi

BACKUP_OUTPUT=$(ssh -i "$SSH_PRIVATE_KEY" root@"$PROXMOX_HOST" "vzdump $VM_CT_ID --storage=\"$PBS_STORAGE\" 2>&1")
if [[ $BACKUP_OUTPUT =~ "error" ]]; then
    messages+=("$(echo_message -e "Backup process failed. Error: $BACKUP_OUTPUT" "" true)")
else
    messages+=("$(echo_message -e "Backup process completed." false)")
fi

end_script 0
