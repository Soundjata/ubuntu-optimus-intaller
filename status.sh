#!/bin/bash
source /etc/optimus/functions.sh

if [ ! -z $LAST_UPGRADE ]; then output $OUTPUT_MODE '' 'green' 200 'upgrade' 100; fi