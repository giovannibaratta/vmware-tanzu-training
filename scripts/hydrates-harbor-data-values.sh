#!/bin/bash
#
# This script can be used to copy the stub file containing harbor secrets to the current directory
# and to produce the a merge file of the harbor config file and the file containing the secrets.
# The script also add the files containing the secrets to .gitignore.
#
# Usage: ./script gen-template|hydrates


set -e
set -u
set -o pipefail

readonly SECRETS_FILE_NAME="harbor-data-values-secrets.yaml"
readonly CONFIG_FILE_NAME="harbor-data-values-no-secrets.yaml"
readonly HYDRATED_FILE_NAME="harbor-data-values.yaml"

function main(){
    local command="${1?'Available commands gen-template|hydrates'}"
 
    if [[ "${command}" == "gen-template" ]]; then
        gen_template
    elif [[ "${command}" == "hydrates" ]]; then
        hydrates
    else
        err 'Unsupported command. Available commands gen-template|hydrates'
        exit 1
    fi
}

#######################################
# Copy the stub file to the current directory
# Globals:
#   SECRETS_FILE_NAME
#   SCRIPT_DIR
#######################################
function gen_template(){
    local cur_dir
    cur_dir=$(pwd)
    local dst_file_name="harbor-data-values-secrets.yaml"
    local dst_file_path="${cur_dir}/${SECRETS_FILE_NAME}"

    if [[ -f "${dst_file_path}" ]]; then
        err "Template file ${dst_file_name} already exists"
        exit 1
    fi

    cp "${SCRIPT_DIR}/configuration-files-examples/harbor-data-values-secrets-template.yaml" \
        "${dst_file_path}"

    echo "Template file copied to ${dst_file_path}"

    if ! grep -E "^$SECRETS_FILE_NAME" ".gitignore" > /dev/null; then
        echo -e "\n${SECRETS_FILE_NAME}" >> ".gitignore"
        echo "Added ${SECRETS_FILE_NAME} to .gitignore"
    fi
}

#######################################
# Merge the configuration file and the file containing the secrets
# Globals:
#   SECRETS_FILE_NAME
#   CONFIG_FILE_NAME
#   HYDRATED_FILE_NAME
#######################################
function hydrates(){
    local cur_dir
    cur_dir=$(pwd)

    if [[ ! -f "${SECRETS_FILE_NAME}" ]]; then
        err "File ${SECRETS_FILE_NAME} does not exist"
        exit 1
    fi

    if [[ ! -f "${CONFIG_FILE_NAME}" ]]; then
        err "File ${CONFIG_FILE_NAME} does not exist"
        exit 1
    fi

    if ! grep -E "^$HYDRATED_FILE_NAME" ".gitignore" > /dev/null; then
        echo -e "\n${HYDRATED_FILE_NAME}" >> ".gitignore"
        echo "Added ${HYDRATED_FILE_NAME} to .gitignore"
    fi

    yq ea '. as $item ireduce ({}; . * $item )' \
        "${CONFIG_FILE_NAME}" \
        "${SECRETS_FILE_NAME}" > "${HYDRATED_FILE_NAME}"
}

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

SCRIPT_DIR=$(echo "$0" | rev | cut -d'/' -f2- | rev)
main "$@"