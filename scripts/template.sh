#!/usr/bin/env bash

set -e
set -u
set -o pipefail

function main() {
  echo "Hello world"
}

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*" >&2
}

function info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

function err_and_exit() {
  err "$*"
  exit 1
}

#######################################
# Entrypoint
#######################################
main "$@"