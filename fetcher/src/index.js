import fetch from "node-fetch";
import dotenv from "dotenv";
import { writeFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: resolve(__dirname, "../../.env") });

const query = `{
  user(login: "RukshanRanasinghe2000") {
    pinnedItems(first: 6, types: REPOSITORY) {
      nodes {
        ... on Repository {
          name
          description
          stargazerCount
          url
          isFork
          primaryLanguage {
            name
          }
        }
      }
    }
  }
}`;

const response = await fetch("https://api.github.com/graphql", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${process.env.GITHUB_TOKEN}`,
    "Content-Type": "application/json"
  },
  body: JSON.stringify({ query })
});

if (!response.ok) {
  console.error("GitHub API error:", response.status);
  process.exit(1);
}

const { data } = await response.json();
const repos = data.user.pinnedItems.nodes;

const outPath = resolve(__dirname, "../../static/repos.json");
writeFileSync(outPath, JSON.stringify(repos, null, 2));
console.log(`Wrote ${repos.length} pinned repos to static/repos.json`);
