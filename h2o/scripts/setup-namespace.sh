#!/bin/bash

# The script read a yaml file and configure the vSphere namespaces accordigly to the content
# of the file. The script DOES not delete existing namespaces if they are not defined
# in the configuration file. It will also not update the supervisor reference of the namespace.
#
# Usage: setup-namespace <VCENTER_SERVER> <VCENTER_USERNAME> <PATH_TO_FILE_CONTAINING_NS_DEFINITION>
#
# The script is not race-conditions safe and it might fail if other entities are
# removing/updating objects form the system.

set -e
set -u
set -o pipefail

function main() {

  local host="${1?vsphere host is missing}"
  local user="${2?vpshere user is missing}"
  local configuration_file="${3?configuration file is missing}"
  local TMP_CONFIGURATION_FILE
  local namespaces

  readonly BASE_URL="https://${host}" 
  TMP_CONFIGURATION_FILE="/tmp/setup-namespaces-$(date +%s).tmp"

  # Create a copy of the file because the subsequent commands
  # will read its content several time during execution
  cp "$configuration_file" "$TMP_CONFIGURATION_FILE"

  login_to_vpshere "$user"

  namespaces=$(yq '.namespaces.[] | .name' "$TMP_CONFIGURATION_FILE")

  # Do not quote namespaces to let bash do word expansion
  for namespace in $namespaces; do
    setup_namespace "${namespace}"
  done

  rm "$TMP_CONFIGURATION_FILE"
}

#######################################
# Configure a single namespace using the specs defined in the configuration file.
# The namespace will be created if it does not exist.
# Arguments:
#   namespace to create/configure.
#######################################
function setup_namespace () {
  local namespace="${1?namespace not set or empty}"

  if does_vsphere_namespace_exists "${namespace}"; then
    info "Namespace ${namespace} already exists, skip creation."
  else
    create_vsphere_namespace "${namespace}"
  fi

  update_vmclasses "${namespace}"
  update_storagepolicies "${namespace}"
}

#######################################
# Set the VM classes defined in the configuration file for an existing namespace
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   TMP_CONFIGURATION_FILE
# Arguments:
#   namespace to update. This namespace must be defined in the configuration file.
#######################################
function update_vmclasses () {
  local namespace="${1?namespace not set or empty}"
  local vm_classes_json_array

  vm_classes_json_array=$(yq '.namespaces.[] | select(.name=="'"${namespace}"'") | .vmClasses' "$TMP_CONFIGURATION_FILE" -o=json | jq --compact-output)

  curl -X PATCH --silent \
    --fail-with-body \
    --location "${BASE_URL}/api/vcenter/namespaces/instances/${namespace}" \
    --header "${SESSION_HEADER}" \
    --header 'Content-Type: application/json' \
    --data '{
      "vm_service_spec": {
        "vm_classes": '"$vm_classes_json_array"'
      }
     }'

  info "VM classes updated successfully for namespace ${namespace}"
}

#######################################
# Set the storage policies defined in the configuration file for an existing namespace
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   TMP_CONFIGURATION_FILE
# Arguments:
#   namespace to update. This namespace must be defined in the configuration file.
#######################################
function update_storagepolicies () {
  local namespace="${1?namespace not set or empty}"
  local required_storage_policies
  local available_storage_policies
  
  required_storage_policies=$(yq '.namespaces.[] | select(.name=="'"${namespace}"'") | .storagePolicies.[]' "$TMP_CONFIGURATION_FILE")

  # https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/storage/policies/get/
  available_storage_policies=$(curl --silent \
    --fail-with-body \
    --location "${BASE_URL}/api/vcenter/storage/policies" \
    --header "${SESSION_HEADER}" | jq '.[] | {id: .policy, name: .name}')

  local storage_policies_block="["

  for storage_policy in $required_storage_policies; do
    # Lookup the storage policy id from the available policies
    storage_policy_id=$(echo $available_storage_policies | jq 'select (.name=="'"$storage_policy"'") | .id' --raw-output | head -n 1)

    if [[ -z "$storage_policy_id" ]]; then
      err "Unable to lookup storage policy id for policy ${storage_policy}"
      exit 1
    fi

    storage_policies_block="$storage_policies_block,{
      \"policy\": \"$storage_policy_id\"
    }"

    storage_policy_id=""
  done

  storage_policies_block="$storage_policies_block]"

  # Remove extra comma at the beginning ([, -> [)
  storage_policies_block="${storage_policies_block//\[,/\[}"

  curl -X PATCH --silent \
    --fail-with-body \
    --location "${BASE_URL}/api/vcenter/namespaces/instances/${namespace}" \
    --header "${SESSION_HEADER}" \
    --header 'Content-Type: application/json' \
    --data '{
      "storage_specs": '"$storage_policies_block"'
     }'

  info "Storage policies updated successfully for namespace ${namespace}"
}

#######################################
# Check if a namespace is already defined in vSphere
# Globals:
#   BASE_URL
#   SESSION_HEADER
# Arguments:
#   namespace name
# Returns:
#   0 if the namespace exists, 1 otherise 
#######################################
function does_vsphere_namespace_exists () {
  local namespace="${1?namespace not set or empty}"
  local get_ns_status_code

  get_ns_status_code=$(curl --silent --location "${BASE_URL}/api/vcenter/namespaces/instances/v2/$namespace" --header "${SESSION_HEADER}" -w "\n%{http_code}\n" | tail -n 1)

  if [[ "$get_ns_status_code" -ne 200 && "$get_ns_status_code" -ne 404 ]]; then
    err "Unsupported status code $get_ns_status_code"
    exit 1
  fi

  if [[ "$get_ns_status_code" -eq 200 ]]; then
    return 0
  fi

  return 1
}

#######################################
# Retrieve the list of available supervsior
# and return a list of json items
# Globals:
#   BASE_URL
#   SESSION_HEADER
# Returns:
#   json items containing the supervisor id and name
#######################################
function list_supervisors() {
  # https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/namespace-management/supervisors/summaries/get/

  curl --silent \
    --fail-with-body \
    --location "${BASE_URL}/api/vcenter/namespace-management/supervisors/summaries" \
    --header "${SESSION_HEADER}" | jq '.items.[] | {id: .supervisor, name: .info.name}' \
    --raw-output \
    --compact-output
}

#######################################
# Create a non-existing namespace using
# the supervisor defined in the configuration file
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   TMP_CONFIGURATION_FILE
# Arguments:
#   namespace to create
#######################################
function create_vsphere_namespace () {
  local namespace="${1?namespace not set or empty}"
  local supervisor_name
  local supervisors
  local supervisor_id

  # Extract the supervisor name from the configuration file
  supervisor_name=$(yq '.namespaces.[] | select(.name=="'"${namespace}"'") | .supervisor' "$TMP_CONFIGURATION_FILE")

  if [[ -z "$supervisor_name" ]]; then
    err "Supervisor is not defined for namespace ${namespace}"
    exit 1
  fi

  # Retrieve the list of available supervisors
  supervisors=$(list_supervisors)

  # Lookup the supervisor id using the supervisor name
  supervisor_id=$(echo "$supervisors" \
    | jq ' . | select(.name=="'"$supervisor_name"'") | .id' --raw-output --compact-output )

  if [[ -z "$supervisor_id" ]]; then
    err "Unable to identify supervisor id"
    exit 1
  fi

  curl --silent \
    --fail-with-body \
    --location "${BASE_URL}/api/vcenter/namespaces/instances/v2/" \
    --header "${SESSION_HEADER}" \
    --header 'Content-Type: application/json' \
    --data '{
       "namespace": "'"${namespace}"'",
       "supervisor": "'"${supervisor_id}"'"
     }'

  info "Namespace ${namespace} created successfully"
}

#######################################
# Generate a session token can be used in 
# subsequent requests. The token is set to
# a global variable to avoid to pass it around for
# every REST request.
# Globals:
#   BASE_URL
#   SESSION_HEADER
# Arguments:
#   username to use for login
#######################################
function login_to_vpshere () {
  local vsphere_user="${1?vsphere user not set or empty}"
  local password=""
  local auth_basic_token
  local session_token

  echo -n "Password:"
  IFS= read -rs password
  echo
  echo

  auth_basic_token=$(echo -n "$vsphere_user:$password" | base64)

  # Clean password
  password=""

  # The API return the token wrapped in double quotes.
  # || true it is necessary to continue for the error handling
  session_token=$(curl \
    --silent \
    --fail-with-body \
    --location \
    --request POST "${BASE_URL}/api/session" \
    --header "Authorization: Basic $auth_basic_token" \
    | cut -d'"' -f2 \
    || true)

  if [[ "$?" -ne 0 || -z "${session_token}" ]]; then
    err "Unable to retrieve session token"
    exit 1
  fi

  readonly SESSION_HEADER="vmware-api-session-id: $session_token"
}

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*"
}

#######################################
# Entrypoint
#######################################
main "$@"