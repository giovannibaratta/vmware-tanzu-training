#!/usr/bin/env bash

set -e
set -u
set -o pipefail

function main() {
}

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*" >&2
}

info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

#######################################
# Entrypoint
#######################################
main "$@"