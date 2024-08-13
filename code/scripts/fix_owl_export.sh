#!/bin/bash

# turns on debugging mode which will allow
# us to see the filenames passed to the
# awk command
set -x

# passes the 
awk -f fix_owl_dates.awk %1 > %2

if [ $? -ne 0 ]; then
    echo "Unable to fix dates in OWL export file: %1"
	exit 1
fi