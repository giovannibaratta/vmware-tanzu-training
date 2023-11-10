#!/bin/bash

set -e
set -u
set -o pipefail

source ../common/logging.sh
source ../common/vsphere.sh
source ../common/curl.sh

function main() {
  local host="${1?vsphere host is missing}"
  local user="${2?vpshere user is missing}"
  local supervisor_definition_file="${3?missing supervisor definition}"
  local supervisor_secrets_definition_file="${4?missing supervisor secrets definition}"

  local cluster_name
  local cluster_id
  local supervisor_name
  local definition_files_content

  generate_curl_temporary_config

  readonly BASE_URL="https://${host}" 
  login_to_vpshere "$user"

  definition_files_content=$(merge_yaml_files "$supervisor_definition_file" "$supervisor_secrets_definition_file")
  definition_json=$(convert_yaml_to_json "$definition_files_content")

  cluster_name=$( jq '.cluster' --raw-output <<< "${definition_json}" )
  supervisor_name=$( jq '.supervisorName' --raw-output <<< "${definition_json}" )

  if ! cluster_id=$(get_cluster_id "${cluster_name}"); then
    err_and_exit "Unable to lookup cluster id for cluster ${cluster_name}"
  fi

  request_payload=$(generate_json_payload_from_definition_file "${definition_json}")

  if ! check_if_supervisor_exist "${supervisor_name}"; then
    info "Start supervisor provisioning"

    if create_single_zone_supervisor "${cluster_id}" "$request_payload"; then
      info "Supervisor cluster provisioning started successfully"
    else
      err_and_exit "Supervisor cluster provisioning failed"
    fi
  else
    info "Supervisor ${supervisor_name} already exists. Skipping supervisor provisioning."
  fi
}

# Merge two json objects into one
function merge_yaml_files () {
  for file in "$@"; do
    if [[ ! -f "$file" ]]; then
      err_and_exit "file $file does not exist"
    fi
  done

  yq ea '. as $item ireduce ({}; . * $item )' "$@"
}

# Read a yaml object into a json object
function convert_yaml_to_json () {
  local object="${1?missing input}"
  yq -o json <<< "${object}"
}

#######################################
# Given a definition file of a supervisor, generate a API complaint json object
# See https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/namespace-management/supervisors/clusteractionenable_on_compute_cluster/post/
# Arguments:
#   json content of the definition file
#   json content of file containing secrets
# Returns:
#   json object complaint to API specs
#######################################
function generate_json_payload_from_definition_file () {
  local json_content="${1?missing definition file}"
  local requested_storage_policy_name
  local requested_storage_policy_id
  local requested_mgmt_network_name
  local requested_mgmt_network_id
  local requested_workload_network_name
  local requested_workload_network_id
  local zone
  local supervisor_name
  local cp_gateway_cidr
  local cp_first_ip
  local workload_gateway_cidr
  local workload_first_ip
  local services_first_ip
  local workload_range_size
  local services_range_size
  local ntp_server
  local dns_server
  local haproxy_server_port
  local haproxy_server
  local haproxy_port
  local haproxy_cert
  local haproxy_user
  local haproxy_password

  requested_storage_policy_name=$( jq '.storagePolicy' --raw-output <<< "${json_content}" )

  if ! requested_storage_policy_id=$(get_storage_policy_id "${requested_storage_policy_name}"); then
    err "Unable to lookup storage policy id for policy ${requested_storage_policy_name}"
    exit 1
  fi

  # Validate management network
  requested_mgmt_network_name=$( jq '.supervisorControlPlane.portGroupName' --raw-output <<< "${json_content}" )

  if ! requested_mgmt_network_id=$(get_network_id "${requested_mgmt_network_name}"); then
    err "Unable to lookup network id for network ${requested_mgmt_network_name}"
    exit 1
  fi

  # Validate workload network
  requested_workload_network_name=$( jq '.workloadClusters.portGroupName' --raw-output <<< "${json_content}" )

  if ! requested_workload_network_id=$(get_network_id "${requested_workload_network_name}"); then
    err "Unable to lookup network id for network ${requested_workload_network_name}"
    exit 1
  fi

  cp_gateway_cidr=$( jq '.supervisorControlPlane.gatewayCidr' --raw-output <<< "${json_content}" )
  cp_first_ip=$( jq '.supervisorControlPlane.firstIp' --raw-output <<< "${json_content}" )
  supervisor_name=$( jq '.supervisorName' --raw-output <<< "${json_content}" )
  services_first_ip=$( jq '.services.firstIp' --raw-output <<< "${json_content}" )
  services_range_size=$( jq '.services.contiguousUsableIps' --raw-output <<< "${json_content}" )
  workload_gateway_cidr=$( jq '.workloadClusters.gatewayCidr' --raw-output <<< "${json_content}" )
  workload_first_ip=$( jq '.workloadClusters.firstIp' --raw-output <<< "${json_content}" )
  workload_range_size=$( jq '.workloadClusters.contiguousUsableIps' --raw-output <<< "${json_content}" )
  zone=$( jq '.zone' --raw-output <<< "${json_content}" )
  ntp_server=$( jq '.shared.ntp' --raw-output <<< "${json_content}")
  dns_server=$( jq '.shared.dns' --raw-output <<< "${json_content}")
  haproxy_server_port=$( jq '.haproxy.server' --raw-output <<< "${json_content}")
  haproxy_server=$( cut -d':' -f1 <<< "${haproxy_server_port}")
  haproxy_port=$( cut -d':' -f2 <<< "${haproxy_server_port}")
  # Read certficate and replace new line with \n
  haproxy_cert=$( jq '.haproxy.certificate' --raw-output <<< "${json_content}" | awk '{printf "%s\\n", $0}' )
  haproxy_user=$( jq '.haproxy.user' --raw-output <<< "${json_content}")
  haproxy_password=$( jq '.haproxy.password' --raw-output <<< "${json_content}")

  MGMT_NETWORK_ID="${requested_mgmt_network_id}" \
  WORKLOAD_NETWORK_ID="${requested_workload_network_id}" \
  MGMT_GATEWAY_IP_CIDR="${cp_gateway_cidr}" \
  SUP_CP_FIRST_NODE_IP="${cp_first_ip}" \
  STORAGE_POLICY_ID="${requested_storage_policy_id}" \
  SUPERVISOR_NAME="${supervisor_name}" \
  EXT_SERVICES_FIRST_IP="${services_first_ip}" \
  WORKLOAD_GATEWAY_IP_CIDR="${workload_gateway_cidr}" \
  WORKLOAD_NODES_FIRST_IP="${workload_first_ip}" \
  ZONE="${zone}" \
  WORKLOAD_IPS_RANGE_SIZE="${workload_range_size}" \
  SERVICES_IPS_RANGE_SIZE="${services_range_size}" \
  NTP_SERVER="${ntp_server}" \
  DNS_SERVER="${dns_server}" \
  HAPROXY_SERVER="${haproxy_server}" \
  HAPROXY_PORT="${haproxy_port}" \
  HAPROXY_SINGLE_LINE_CERT="${haproxy_cert}" \
  HAPROXY_USER="${haproxy_user}" \
  HAPROXY_PASSWORD="${haproxy_password}" \
    envsubst < "./files/create-single-zone-supervisor-vds-haproxy.json.stub"
}

#######################################
# Entrypoint
#######################################
main "$@"