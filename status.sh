#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE "optimus-installer" "green" 200 "optimus-installer" 100
if [ ! -z $LAST_UPGRADE ]; then output $OUTPUT_MODE "upgrade" "green" 200 "upgrade" 100; fi