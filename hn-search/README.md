# hn-search

Search and monitor Hacker News stories, comments, and users via the free Algolia HN Search API. No API key, no dependencies — just `web_fetch` and structured queries.

## Installation

Copy the `hn-search` folder into your agent's skills directory.

## Usage Examples

### Search for stories on a topic
> "What's Hacker News saying about Rust?"

The agent searches for high-engagement stories about Rust and presents titles, scores, comment counts, and links.

### Monitor for recent mentions
> "Any new HN discussions about our product this week?"

Uses date-sorted search to find the latest stories and comments mentioning the product.

### Find a user's activity
> "What has pg posted on HN recently?"

Filters by author to show a user's recent stories and comments.

## API

Uses the [Algolia HN Search API](https://hn.algolia.com/api):
- **Free** — no API key needed
- **10,000 requests/hour** rate limit
- **Near real-time** indexing of all public HN content
- Supports filtering by type (story, comment, Show HN, Ask HN), score, date, and author

## License

MIT
