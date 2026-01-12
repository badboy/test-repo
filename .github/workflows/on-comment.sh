#!/bin/bash

set -eux

STATUSES_URL=$(curl "https://api.github.com/repos/badboy/test-repo/pulls/${PR_NUMBER}" | jq -r .statuses_url)
curl "$STATUSES_URL" > statuses.json
cat statuses.json

<statuses.json jq '.[] | select(.state=="pending")'
