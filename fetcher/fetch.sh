#!/bin/bash
set -e

QUERY='{"query":"{ user(login: \"RukshanRanasinghe2000\") { pinnedItems(first: 6, types: REPOSITORY) { nodes { ... on Repository { name description stargazerCount url isFork primaryLanguage { name } } } } } }"}'

curl -s -X POST https://api.github.com/graphql \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$QUERY" \
  | jq '.data.user.pinnedItems.nodes' > static/repos.json

echo "Wrote $(jq length static/repos.json) pinned repos to static/repos.json"
