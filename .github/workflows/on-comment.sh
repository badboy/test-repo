#!/bin/bash

set -eux

permission=$(gh api /repos/badboy/test-repo/collaborators/${ACTOR}/permission | jq -r .permission)
if [[ "$permission" = "admin" ]] || [[ "$permission" = "write" ]]; then
  true
else
  echo "User without permission. Ignoring."
  exit 0
fi

statuses_url=$(gh api "/repos/badboy/test-repo/pulls/${PR_NUMBER}" | jq -r .statuses_url)
curl "$statuses_url" > statuses.json

workflow_url=$(<statuses.json jq '.[] | select(.state=="pending" and .context=="ci/circleci: ci/hold") | .target_url' -r | uniq)
workflow_id=$(echo "$workflow_url" | cut -d'/' -f 5)
echo "Workflow ID: $workflow_id"

if [[ -z "$workflow_id" ]]; then
  echo "workflow ID is missing"
  exit 0
fi

job_id=$(curl --request GET \
  "https://circleci.com/api/v2/workflow/$workflow_id/job" \
  --header "Circle-Token: $CIRCLE_TOKEN" | jq -r '.items[] | select(.name=="hold" and .status=="on_hold") | .id')

if [[ -z "$job_id" ]]; then
  echo "job ID is missing"
  exit 0
fi

echo "Approving job with job ID $job_id"
curl --request POST \
  "https://circleci.com/api/v2/workflow/$workflow_id/approve/$job_id" \
  --header "Circle-Token: $CIRCLE_TOKEN"
