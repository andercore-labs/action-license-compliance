#!/bin/bash

source common_functions.sh

csv_file="$1"
repository_name="$GITHUB_REPOSITORY"
workflow_run_id="$GITHUB_RUN_ID"
action_summary_link="${GITHUB_SERVER_URL}/${repository_name}/actions/runs/${workflow_run_id}"
dependencies_count=$(($(cat "$1" | wc -l) - 0))

slack_data=$(construct_slack_message "$csv_file" "$dependencies_count")
echo "$slack_data" >slack_message.json
