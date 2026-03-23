#!/bin/bash
set -e

if [ -z "${GITHUB_TOKEN}" ]; then
  echo "Error: GITHUB_TOKEN is not set."
  exit 1
fi

QUERY='{"query":"{ user(login: \"RukshanRanasinghe2000\") { pinnedItems(first: 6, types: REPOSITORY) { nodes { ... on Repository { name description stargazerCount url isFork primaryLanguage { name } } } } } }"}'

mkdir -p data
RESPONSE=$(curl -s -X POST https://api.github.com/graphql \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$QUERY")

echo "$RESPONSE" | jq '.data.user.pinnedItems.nodes // []' > "${GITHUB_WORKSPACE:-$(pwd)}/data/projects.json"

echo "Wrote $(jq length "${GITHUB_WORKSPACE:-$(pwd)}/data/projects.json") pinned repos to data/projects.json"
