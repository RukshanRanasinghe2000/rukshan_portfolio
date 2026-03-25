# rukshan_portfolio

This is my portfolio site, built with Zola, HTMX, and Tailwind CSS. It pulls pinned GitHub repositories and Medium blog posts at build time and bakes them into the static output — no client-side API calls, no backend.

## How it works

The site is a single-page layout with a fixed sidebar and an HTMX-powered content area. Navigating between sections swaps the content without a full page reload.

Data is fetched before the build runs. A shell script calls the GitHub GraphQL API to get pinned repos and the Medium RSS feed to get blog posts. Both are saved as JSON files that Zola reads during the build using `load_data`.

## Stack

- Zola — static site generator
- HTMX — partial page swaps without JavaScript frameworks
- Tailwind CSS — styling via CDN (build-time replacement planned)
- GitHub Actions — automated build and deploy pipeline

## Local development

You need Zola installed. Then run the fetcher once to populate the data files:

```bash
cd fetcher
bash fetch.sh
```

This requires a `GITHUB_TOKEN` environment variable with `read:user` scope set locally. Then start the dev server:

```bash
zola serve
```

The site will be available at `http://127.0.0.1:1111`.

## Deployment

Pushing to `main` triggers a GitHub Actions workflow that:

1. Fetches fresh data from GitHub and Medium
2. Commits the updated JSON files back to `main`
3. Builds the site with Zola
4. Deploys the output to the `release` branch

GitHub Pages serves the site from the `release` branch.

The workflow also runs on a daily schedule to keep the data fresh without needing a manual push.

## Environment

Add a `GIT_TOKEN_API` secret to your repository with a GitHub personal access token. The token needs `read:user` scope to access pinned repositories via the GraphQL API.

## License

MIT
