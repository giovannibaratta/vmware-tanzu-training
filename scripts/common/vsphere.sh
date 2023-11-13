#!/bin/bash

#######################################
# Generate a session token that can be used in subsequent requests. 
# The token is injected into a header that can be used with CURL, the header is saved in a global
# variable to avoid to pass ans used for REST requests.
# ENVS:
#   VSPHERE_PWD Password to use for authenticating the user
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Arguments:
#   username to use for login
#######################################
function login_to_vpshere () {
  local vsphere_user="${1?vsphere user not set or empty}"
  local password="${VSPHERE_PWD-}"
  local auth_basic_token
  local session_token

  if [[ -z "${password}" ]]; then
    echo -n "Password:"
    IFS= read -rs password
    echo
    echo
  fi

  auth_basic_token=$(echo -n "$vsphere_user:$password" | base64)

  # The API return the token wrapped in double quotes.
  # || true it is necessary to continue for the error handling
  session_token=$(curl \
    --config "${CURL_CONFIG}" \
    --request POST "${BASE_URL}/api/session" \
    --header "Authorization: Basic $auth_basic_token" \
    | cut -d'"' -f2 \
    || true)

  # Clean password
  password=""
  auth_basic_token=""

  if [[ "$?" -ne 0 || -z "${session_token}" ]]; then
    err "Unable to retrieve session token"
    exit 1
  fi

  export SESSION_HEADER="vmware-api-session-id: $session_token"
}

#######################################
# List of the storage policies available in the vCenter.
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Return:
#   JSON array containing the policies: { id, name }[]
#######################################
function list_storage_policies () {
  local response
  response=$(curl --config "${CURL_CONFIG}" \
    --header "${SESSION_HEADER}" \
    "${BASE_URL}/api/vcenter/storage/policies")

  # Remap properties and return as an JSON array
  jq '.[] | {id: .policy, name: .name}' <<< "${response}" | jq -n '[inputs]'
}

#######################################
# Retrieve the storage policy id for a given storage policy name. 
# If the policy can not be found return 1.
# Arguments:
#   storage policy name
# Return:
#   storage policy id associated to the storage policy name
#######################################
function get_storage_policy_id () {
  local requested_storage_policy_name="${1?storage policy name required}"
  local available_storage_policies=
  local storage_policy_id=

  available_storage_policies=$(list_storage_policies)

  storage_policy_id=$(jq --raw-output '.[] | select (.name=="'"${requested_storage_policy_name}"'") | .id' <<< "${available_storage_policies}")

  if [[ -z "$storage_policy_id" ]]; then
    # Policy not found
    return 1
  fi

  echo "$storage_policy_id"
}

#######################################
# Retrieve the network id for a given network name. If the network can not be found return 1.
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Arguments:
#   network name
# Return:
#   network id associated to the network name
#######################################
function get_network_id () {
  local requested_network_name="${1?network name required}"
  local response

  response=$(curl --config "${CURL_CONFIG}" \
    --header "${SESSION_HEADER}" \
    --get \
    "${BASE_URL}/api/vcenter/network" \
    --data-urlencode "names=${requested_network_name}")

  if [[ "${response}" == "[]" ]]; then
    # Network not found
    return 1
  fi

  # Pick first item of the list and return the network field
  jq '.[0].network' --raw-output <<< "${response}"
}

#######################################
# Create a single-zone supervisor cluster
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Arguments:
#   cluster id of where the supervisor should be deployed
#   json payload to send to the api. See https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/namespace-management/supervisors/clusteractionenable_on_compute_cluster/post/
#######################################
function create_single_zone_supervisor () {
  local cluster_id="${1?missing cluster id}"
  local request_body="${2?missing request payload}"

  curl --config "${CURL_CONFIG}" \
      "${BASE_URL}/api/vcenter/namespace-management/supervisors/${cluster_id}?action=enable_on_compute_cluster" \
      --header "${SESSION_HEADER}" \
      --header 'Content-Type: application/json' \
      --data "$request_body" > /dev/null
}

#######################################
# Check if a supevisor with the given name already exists
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Arguments:
#   supervisor name
# Exit codes:
#   0 if the supervisor exists
#   1 otherwise
#######################################
function check_if_supervisor_exist () {
  local supervisor_name="${1?missing supervisor_name}"
  get_supervisor_id "$supervisor_name" > /dev/null
}

#######################################
# Get the supervisor id given the supervisor name
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Arguments:
#   supervisor name
# Return:
#   the supervisor id
# Exit codes:
#   0 if the output of the command contains the supervisor id
#   1 otherwise
#######################################
function get_supervisor_id () {
  local supervisor_name="${1?missing supervisor_name}"
  local response
  local supervisor_id

  response=$(curl --config "${CURL_CONFIG}" \
    --header "${SESSION_HEADER}" \
    "${BASE_URL}/api/vcenter/namespace-management/supervisors/summaries")

  supervisor_id=$(jq '.items.[] | select(.info.name=="'"${supervisor_name}"'" ) | .supervisor' --raw-output <<< "${response}")

  if [[ -z "$supervisor_id" ]]; then
    return 1
  fi

  echo "${supervisor_id}"
}

#######################################
# Retrieve the cluster id for a given cluster name. If the cluster can not be found return 1.
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Arguments:
#   cluster name
# Return:
#   cluster id associated to the cluster name
#######################################
function get_cluster_id () {
  local requested_cluster_name="${1?cluster name required}"
  local response

  response=$(curl --config "${CURL_CONFIG}" \
    --header "${SESSION_HEADER}" \
    --get \
    "${BASE_URL}/api/vcenter/cluster" \
    --data-urlencode "names=${requested_cluster_name}")

  if [[ "${response}" == "[]" ]]; then
    # Cluster not found
    return 1
  fi

  # Pick first item of the list and return the cluster field
  jq '.[0].cluster' --raw-output <<< "${response}"
}

#######################################
# List of identity providers attached to the supervisor.
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Arguments:
#  supervisor id
# Return:
#   JSON array containing the policies: { id, name }[]
#######################################
function list_identity_providers () {
  local supervisor_id="${1?supervisor_id missing}"

  local response
  response=$(curl --config "${CURL_CONFIG}" \
    --header "${SESSION_HEADER}" \
    "${BASE_URL}/api/vcenter/namespace-management/supervisors/${supervisor_id}/identity/providers")

  # Remap properties and return as a JSON array
  jq '.[] | {id: .provider, name: .display_name}' <<< "${response}" | jq -n '[inputs]'
}

#######################################
# Attach a new identity provider to a supervisor.
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Arguments:
#  supervisor id
#  json payload containing the configuration details. See https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/namespace-management/supervisors/supervisor/identity/providers/post/
#######################################
function create_identity_provider () {
  local supervisor_id="${1?missing supervisor id}"
  local request_body="${2?missing request payload}"

  curl --config "${CURL_CONFIG}" \
      "${BASE_URL}/api/vcenter/namespace-management/supervisors/${supervisor_id}/identity/providers" \
      --header "${SESSION_HEADER}" \
      --header 'Content-Type: application/json' \
      --data "$request_body" > /dev/null
}

#######################################
# Update an existing policy identity provider to a supervisor
# Globals:
#   BASE_URL
#   SESSION_HEADER
#   CURL_CONFIG
# Arguments:
#  supervisor id
#  identity provider id
#  json payload containing the configuration details. See https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/namespace-management/supervisors/supervisor/identity/providers/provider/put/
#######################################
function update_identity_provider () {
  local supervisor_id="${1?missing supervisor id}"
  local provider_id="${2?missing provider id}"
  local request_body="${3?missing request payload}"

  curl --config "${CURL_CONFIG}" \
      -X PUT \
      "${BASE_URL}/api/vcenter/namespace-management/supervisors/${supervisor_id}/identity/providers/${provider_id}" \
      --header "${SESSION_HEADER}" \
      --header 'Content-Type: application/json' \
      --data "$request_body" > /dev/null
}