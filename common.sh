#!/bin/bash

# Function to construct Slack message attachments
construct_slack_message() {
    local csv_file="$1"
    local dependencies_count="$2"

    echo "{
        \"attachments\": [
            {
                \"blocks\": [
                    {
                        \"type\": \"header\",
                        \"text\": {
                            \"type\": \"plain_text\",
                            \"text\": \":warning:  $repository_name\"
                        }
                    }
                ]
            },
            {
                \"blocks\": [
                    {
                        \"type\": \"context\",
                        \"elements\": [
                            {
                                \"type\": \"mrkdwn\",
                                \"text\": \"*$dependencies_count licenses need to be reviewed*\\n\"
                            }
                        ]
                    },
                    {
                        \"type\": \"divider\"
                    },"

    dependencies=$(cat "$1" | tr -d '\r')
    first_line=true

    while IFS=',' read -r line; do
        name=$(echo "$line" | awk -F ',' '{gsub(/"/, "", $1); print $1}')
        license_type=$(echo "$line" | awk -F ',' '{gsub(/"/, "", $2); print $2}')
        dep_url=$(echo "$line" | awk -F ',' '{gsub(/"/, "", $3); print $3}')

        if [ "$first_line" = "true" ]; then
            first_line=false
        else
            echo ","
        fi

        IFS=';' read -ra licenses <<<"$license_type"
        license_text=""

        first_license=true
        for license in "${licenses[@]}"; do
            if [ "$first_license" = true ]; then
                license_text+="\\n•  $license"
                first_license=false
            else
                license_text+="\\n• $license"
            fi
        done

        echo "                {
                        \"type\": \"section\",
                        \"text\": {
                            \"type\": \"mrkdwn\",
                            \"text\": \" *<$dep_url|$name>*$license_text\"
                        }
                    }"
    done <<<"$dependencies"

    echo "            ]
            },
            {
                \"color\": \"#87CEEB\",
                \"blocks\": [
                    {
                        \"type\": \"divider\"
                    },
                    {
                        \"type\": \"section\",
                        \"block_id\": \"section789\",
                        \"fields\": [
                            {
                                \"type\": \"mrkdwn\",
                                \"text\": \"GitHub Action summary: $action_summary_link\"
                            }
                        ]
                    }
                ]
            }
        ]
    }"
}

# Function to process licenses and generate summary
process_licenses() {
    local INPUT_FILE="$1"
    local ALLOW_LIST="$2"
    local BLOCK_LIST="$3"

    if [ $# -ne 3 ]; then
        echo "Usage: $0 <licenses.csv> <allow_list> <block_list>"
        exit 1
    fi

    FAIL_COUNTER=0
    TOTAL_COUNTER=0

    {
        while IFS=',' read -r line; do
            TOTAL_COUNTER=$((TOTAL_COUNTER + 1))

            if ! [[ ${line} =~ $ALLOW_LIST ]] || [[ ${line} =~ $BLOCK_LIST ]]; then
                echo $line >>invalid.csv
                if ! [[ ${line} =~ "Name" ]]; then
                    FAIL_COUNTER=$((FAIL_COUNTER + 1))
                    echo "<tr><td>$FAIL_COUNTER</td><td>:red_circle:</td><td><a href=\"$(echo "$line" | awk -F '\"' '{print $6}')\" target=\"_blank\">$(echo "$line" | awk -F '\"' '{print $2}')</a></td><td>$(echo "$line" | awk -F '\"' '{print $4}')</td></tr>"
                fi
            fi
        done < <(sed 1d "$INPUT_FILE")
    } >>"$GITHUB_STEP_SUMMARY"

    if (($FAIL_COUNTER > 0)); then
        echo -e "\n<h4>$FAIL_COUNTER / $TOTAL_COUNTER licenses need to be researched.</h4>\n"
        echo "::error::Some licenses need to be reviewed" && exit 1
    fi
}
