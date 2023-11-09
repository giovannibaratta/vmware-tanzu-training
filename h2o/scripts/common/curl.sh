#!/bin/bash

#######################################
# Generate a curl configuration file that can be referenced using the flag --config.
# Globals:
#   CURL_CONFIG Path of the configuration file
#######################################
function generate_curl_temporary_config () {
  export CURL_CONFIG="/tmp/curl-config-$(date +%s)"
  touch "${CURL_CONFIG}"

  if [[ "${NO_VERIFY_SSL}" == "TRUE" ]]; then
    echo "insecure" >> "${CURL_CONFIG}"
  fi

  {
    echo "location"
    echo "fail-with-body"
    echo "silent"
  } >> "${CURL_CONFIG}"
}