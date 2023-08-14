# Arazutech: Python License Check GitHub Action

This GitHub Action checks the licenses of Python dependencies and sends notifications if restricted licenses are found. It can be configured to use a Slack webhook to send notifications.

## Inputs

slack_webhook_url (required): Slack webhook URL for sending notifications.\
allow_list (optional): A regex pattern for allowed licenses. Default: '(MIT|BSD|ISC|Apache|CC0)'.\
allow_list (optional): A regex pattern for blocked licenses. Default: '(GPL|AGPL|CDDL|EUPL|LGPL|MPL)'.\
runtime (required): Runtime of project in which to execute the action - "node" or "python".

## Example Usage

```yaml
name: Dependency License Check

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  license-compliance-check:
    runs-on: ubuntu-latest
    env:
      SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
      ALLOW_LIST: {{ vars.LICENSE_ALLOW_LIST }}
      BLOCK_LIST: {{ vars.LICENSE_BLOCK_LIST }}
      RUNTIME: "node"
    steps:            
      - name: Node License Check
        uses: arazutech/action-license-compliance@v50
        with:
          slack_webhook_url: ${{ env.SLACK_WEBHOOK_URL }}
          allow_list: ${{ env.ALLOW_LIST }}
          block_list: ${{ env.BLOCK_LIST }}
          runtime: {{ env.RUNTIME }}


```

## License

This GitHub Action is licensed under the MIT License.
