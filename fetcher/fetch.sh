#!/bin/bash
set -e

# GitHub pinned repos 

if [ -z "${GH_TOKEN}" ]; then
  echo "Error: GH_TOKEN is not set."
  exit 1
fi

QUERY='{"query":"{ user(login: \"RukshanRanasinghe2000\") { pinnedItems(first: 6, types: REPOSITORY) { nodes { ... on Repository { name description stargazerCount url isFork primaryLanguage { name } } } } } }"}'

RESPONSE=$(curl -s -X POST https://api.github.com/graphql \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$QUERY")

echo "GitHub API Response: $RESPONSE"

if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "GraphQL errors:"
  echo "$RESPONSE" | jq '.errors'
  exit 1
fi

PROJECTS_OUT="${GITHUB_WORKSPACE}/data/projects.json"
mkdir -p "$(dirname "$PROJECTS_OUT")"
echo "$RESPONSE" | jq '.data.user.pinnedItems.nodes // []' > "$PROJECTS_OUT"
echo "Saved $(jq length "$PROJECTS_OUT") pinned repos to data/projects.json"

# Medium blog posts 

MEDIUM_FEED="https://medium.com/feed/@rukshanranasinghe2000"
BLOGS_OUT="${GITHUB_WORKSPACE}/data/blogs.json"

echo "Fetching Medium RSS..."
RSS=$(curl -s "$MEDIUM_FEED")

python3 - <<EOF > "$BLOGS_OUT"
import xml.etree.ElementTree as ET
import json, re, sys

rss = """${RSS//\"/\\\"}"""
root = ET.fromstring(rss)
channel = root.find('channel')
items = []

for item in channel.findall('item'):
    title = item.findtext('title', '').strip()
    link = item.findtext('link', '').strip()
    pub_date = item.findtext('pubDate', '').strip()
    description = item.findtext('description', '').strip()
    content = item.findtext('{http://purl.org/rss/1.0/modules/content/}encoded', '').strip()

    categories = [c.text.strip() for c in item.findall('category') if c.text]

    thumbnail = ''
    src_match = re.search(r'<img[^>]+src=["\']([^"\']+)["\']', content or description)
    if src_match:
        thumbnail = src_match.group(1)

    # strip html from description
    clean_desc = re.sub(r'<[^>]+>', '', description).strip()[:200]

    items.append({
        'title': title,
        'link': link,
        'pubDate': pub_date,
        'description': clean_desc,
        'thumbnail': thumbnail,
        'categories': categories[:3],
    })

print(json.dumps(items, indent=2))
EOF

echo "Saved $(jq length "$BLOGS_OUT") blog posts to data/blogs.json"
