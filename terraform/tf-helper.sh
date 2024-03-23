#!/usr/bin/env bash

set -e
set -u
set -o pipefail

ACTION="${1-}"
STAGE="${2-}"

if [[ -z "${ACTION}" || -z "${STAGE}" ]]; then
  echo "Missing parameter"
  echo "$0 <plan|apply> <stage>"
  exit 1
fi

if [[ "${ACTION}" != "plan" && "${ACTION}" != "apply" && "${ACTION}" != "destroy" ]]; then
  echo "Supported action are plan, apply or destroy"
  exit 1
fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
STAGE_DIR="${SCRIPT_DIR}/stages/${STAGE}"

if [[ ! -d "${STAGE_DIR}" ]]; then
  echo "Stage ${STAGE} not found"
  exit 1
fi

TF_CONFIG="${STAGE_DIR}/.terraform-config"

if [[ -f "${TF_CONFIG}" ]]; then
  echo "Loading configuration file ${TF_CONFIG}"
  . "${TF_CONFIG}"
fi

terraform -chdir="${STAGE_DIR}" "${ACTION}"