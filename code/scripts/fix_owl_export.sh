#!/bin/bash

# %1 - Absolute path to the file that needs to be transformed
# %2 - Absolute path to the re-written version of the file
# Pre-condition: fix_owl_dates.awk script must reside in
# the same folder as this script

# turns on debugging mode which will allow
# us to see the filenames passed to the
# awk command
set -x

# Note: %1 could be a glob. We do not want this script to process multiple
# files at once, so we need a check to ensure that the glob would only identify
# a single file. If it identifies no files, or more than 1 file, exit with a
# non-zero error code.

FILE_CT=`ls -1 %1 | wc -l`

if [ $? -ne 0 ]; then
	echo "Error searching for %1"
	exit 1
fi

if [ $FILE_CT -eq 0 ]; then
	echo "%1 not found"
	exit 1
elif [ $FILE_CT -gt 1 ]; then
	echo "Multiple files matched by %1"
	exit 1
else
	echo "%1 found"
fi

# We expect that issues related to reading, execting or writing files will be
# handled by the awk command, and it will return an appropriate error message
# and non-zero error code in those cases
awk -f fix_owl_dates.awk %1 > %2

if [ $? -ne 0 ]; then
    echo "Unable to fix dates in OWL export file: %1"
	exit 1
fi
