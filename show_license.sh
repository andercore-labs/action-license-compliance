#!/bin/bash

INPUT_FILE="$1"
ALLOW_LIST="$2"
BLOCK_LIST="$3"

if [ $# -ne 3 ]; then
    echo "Usage: $0 <licenses.csv> <allow_list> <block_list>"
    exit 1
fi

{
    FAIL_COUNTER=0
    TOTAL_COUNTER=0

    # Count the number of licenses that need to be researched
    while IFS=',' read -r line; do
        TOTAL_COUNTER=$((TOTAL_COUNTER + 1))
        if ! [[ ${line} =~ $ALLOW_LIST ]] || [[ ${line} =~ $BLOCK_LIST ]]; then
            FAIL_COUNTER=$((FAIL_COUNTER + 1))
        fi
    done < <(sed 1d "$INPUT_FILE")

    # Display the message
    echo "<h4>$FAIL_COUNTER / $TOTAL_COUNTER licenses need to be researched.</h4>"
    echo "<table>"
    echo "<th>#</th> <th>Status</th> <th>Name</th> <th>License Type</th>"
} >>"$GITHUB_STEP_SUMMARY"

# Generate the license table
sed 1d "$INPUT_FILE" | while IFS=',' read -r line; do
    ICON=":green_circle:"
    if ! [[ ${line} =~ $ALLOW_LIST ]] || [[ ${line} =~ $BLOCK_LIST ]]; then
        ICON=":red_circle:"
    fi
    if ! [[ ${line} =~ "Name" ]]; then
        echo "<tr>" "<td>$TOTAL_COUNTER</td>" "<td>$ICON</td>" "<td><a href=\"$(echo "$line" | awk -F '\"' '{print $6}')\" target=\"_blank\">$(echo "$line" | awk -F '\"' '{print $2}')</a></td>" "<td>$(echo "$line" | awk -F '\"' '{print $4}')</td>" "</tr>" >>"$GITHUB_STEP_SUMMARY"
    fi
done

echo "</table>" >>"$GITHUB_STEP_SUMMARY"
