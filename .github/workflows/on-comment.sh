#!/bin/bash

set -eux

STATUSES_URL=$(curl https://api.github.com/repos/mozilla/glean/pulls/3371 | jq -r .statuses_url)
curl "$STATUSES_URL" > statuses.json
cat statuses.json

<statuses.json jq '.[] | select(.state=="pending")'
