#!/bin/bash

set -e

REF="${1-main}"

CURRENT_DIR=$(pwd)

git clone https://github.com/dockersamples/example-voting-app.git /tmp/voting-app > /dev/null 2>&1
cd /tmp/voting-app
git checkout "$REF" > /dev/null 2>&1
cd "${CURRENT_DIR}"
rm -rf voting-app > /dev/null 2>&1
cp -a /tmp/voting-app/k8s-specifications/ "./voting-app"
rm -rf /tmp/voting-app > /dev/null 2>&1

echo "Application cloned successfully in voting-app"