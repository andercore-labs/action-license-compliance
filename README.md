# Arazutech: License Checker

This GitHub Action checks the licenses of Python dependencies and sends notifications if restricted licenses are found. It can be configured to use a Slack webhook to send notifications.

## Inputs

slack_webhook_url (required): Slack webhook URL for sending notifications.
allow_list (optional): A regex pattern for allowed licenses. Default: '(MIT|BSD|ISC|Apache|CC0|buyer-app)'.

## Example Usage

```yaml
name: 'Arazutech: Python License Check'
description: 'Checks the licenses of Python dependencies and sends notifications if restricted licenses are found'
inputs:
  slack_webhook_url:
    description: 'Slack webhook URL for sending notifications'
    required: true
  allow_list:
    description: 'Regex pattern for allowed licenses'
    default: '(MIT|BSD|ISC|Apache|CC0|buyer-app)'
runs:
  using: 'composite'
  steps:

    - name: 'Check for restricted licenses'
      run: |
        chmod +x ${{ github.action_path }}/license_check.sh
        ${{ github.action_path }}/license_check.sh licenses.csv "${{ inputs.allow_list }}"
      shell: bash

    - name: 'Show all license info'
      run: |
        chmod +x ${{ github.action_path }}/show_license.sh
        ${{ github.action_path }}/show_license.sh licenses.csv
      shell: bash
      if: always()

    - name: 'Format output to JSON'
      run: |
        chmod +x ${{ github.action_path }}/create_json.sh
        ${{ github.action_path }}/create_json.sh invalid.csv
      shell: bash
      if: always()

    - name: 'POST JSON'
      run: |
        json_data=$(cat slack_message.json)
        escaped_json_data=$(echo "$json_data" | jq -c .)
        curl -X POST -H 'Content-type: application/json' --data "$escaped_json_data" ${{ inputs.slack_webhook_url }}
      shell: bash
      if: always()
```

## License

This GitHub Action is licensed under the MIT License.
