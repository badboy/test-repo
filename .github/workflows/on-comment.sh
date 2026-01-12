#!/bin/bash

set -eux

STATUSES_URL=$(curl "https://api.github.com/repos/badboy/test-repo/pulls/${PR_NUMBER}" | jq -r .statuses_url)
curl "$STATUSES_URL" > statuses.json
cat statuses.json

workflow_url=$(<statuses.json jq '.[] | select(.state=="pending" and .context=="ci/circleci: ci/hold") | .target_url' -r | uniq)
workflow_id=$(echo "$workflow_url" | cut -d'/' -f 5)
echo "Workflow ID: $workflow_id"

if [[ -n "$workflow_id" ]]; then
  echo "workflow ID is missing"
  exit 0
fi

job_id=$(curl --request GET \
  "https://circleci.com/api/v2/workflow/$workflow_id/job" \
  --header "Circle-Token: $CIRCLE_TOKEN" | jq -r '.items[] | select(.name=="hold" and .status=="on_hold") | .id')
echo "Job ID: $job_id"

if [[ -n "$job_id" ]]; then
  echo "job ID is missing"
  exit 0
fi
