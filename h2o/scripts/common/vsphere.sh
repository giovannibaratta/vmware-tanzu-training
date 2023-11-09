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
  local password="${VSPHERE_PWD}"
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
      --data "$request_body"
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