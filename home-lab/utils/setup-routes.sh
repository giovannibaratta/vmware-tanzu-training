#!/bin/bash

# Only tested in MacOs

PFSENSE_IP="172.16.0.48"

route -n add -net 172.17.0.0/16 "$PFSENSE_IP"
route -n add -net 172.18.0.0/16 "$PFSENSE_IP"