#!/bin/bash

TOTAL_COUNTER=0
FAIL_COUNTER=0
INPUT_FILE="$1"
ALLOW_LIST="$2"
BLOCK_LIST="$3"

if [ $# -ne 3 ]; then
    echo "Usage: $0 <licenses.csv> <allow_list>"
    exit 1
fi

{
    echo "<h4>Invalid licences</h4>"
    echo "<table>"
    echo "<th>#</th> <th>Status</th> <th>Name</th> <th>License Type</th>"
} >>"$GITHUB_STEP_SUMMARY"

while IFS=',' read -r line; do
    TOTAL_COUNTER=$((TOTAL_COUNTER + 1))

    # Check if the license does not match the ALLOW_LIST or contains "GPL"
    if ! [[ ${line} =~ $ALLOW_LIST ]] || [[ ${line} =~ $BLOCK_LIST ]]; then
        echo $line >>invalid.csv
        if ! [[ ${line} =~ "Name" ]]; then
            FAIL_COUNTER=$((FAIL_COUNTER + 1))
            echo "<tr><td>$FAIL_COUNTER</td><td>:red_circle:</td><td><a href=\"$(echo "$line" | awk -F '\"' '{print $6}')\" target=\"_blank\">$(echo "$line" | awk -F '\"' '{print $2}')</a></td><td>$(echo "$line" | awk -F '\"' '{print $4}')</td></tr>" >>"$GITHUB_STEP_SUMMARY"
        fi
    fi
done < <(sed 1d "$INPUT_FILE")
echo "</table>" >>"$GITHUB_STEP_SUMMARY"

if (($FAIL_COUNTER > 0)); then
    echo -e "\n<h4>$FAIL_COUNTER / $TOTAL_COUNTER licenses need to be researched.</h4>\n" >>"$GITHUB_STEP_SUMMARY"
    echo "::error::Some licenses need to be reviewed" && exit 1
fi
