#!/bin/bash

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

err_and_exit() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  exit 1
}

info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*"
}