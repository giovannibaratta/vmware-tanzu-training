#!/usr/bin/env bash

set -e
set -u
set -o pipefail

function main() {
  # Check if there are pending changes first to preserve the content that has not been commited.
  if ! is_already_committed README.md; then
    err "There are pending changes to README.md that have not been committed"
    exit 1
  fi

  # Regnerate the README and check if there are diffs
  bash ./scripts/generate-folder-structure.sh README.md > /dev/null

  if ! is_already_committed README.md; then
    err "The README.md contains changes that must be verified and commited."
    exit 1
  fi
}

# Check if the specified file is the same that has been committed.
# Args:
#   file to check
# Returns:
#   0 if the file is already committed
#   1 if the file has been changed
function is_already_committed() {
  local file="$1"
  git diff --exit-code -s "${file}" && git diff --exit-code -s --staged "${file}"
}

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*" >&2
}

#######################################
# Entrypoint
#######################################
main "$@"