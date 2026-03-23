#!/bin/bash
set -e

if [ -z "${GH_TOKEN}" ]; then
  echo "Error: GH_TOKEN is not set."
  exit 1
fi

QUERY='{"query":"{ user(login: \"RukshanRanasinghe2000\") { pinnedItems(first: 6, types: REPOSITORY) { nodes { ... on Repository { name description stargazerCount url isFork primaryLanguage { name } } } } } }"}'

RESPONSE=$(curl -s -X POST https://api.github.com/graphql \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$QUERY")

echo "API Response: $RESPONSE"

if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "GraphQL errors:"
  echo "$RESPONSE" | jq '.errors'
  exit 1
fi

OUT="${GITHUB_WORKSPACE}/data/projects.json"
mkdir -p "$(dirname "$OUT")"
echo "$RESPONSE" | jq '.data.user.pinnedItems.nodes // []' > "$OUT"

echo "Saved file:"
cat "$OUT"
echo "Count: $(jq length "$OUT") pinned repos to data/projects.json"
