# producthunt

Search and monitor Product Hunt launches, products, and makers via the GraphQL V2 API. Track trending products, research competitors, and monitor launches by topic.

## Installation

Copy the `producthunt` folder into your agent's skills directory.

## Requirements

A free Product Hunt API developer token. Get one from the [API Dashboard](https://www.producthunt.com/v2/oauth/applications). Set it as `PH_API_TOKEN` environment variable.

Falls back to web search if no token is available (with limited data).

## Usage Examples

### Find today's top launches
> "What launched on Product Hunt today?"

### Research a specific product
> "How did Linear do on Product Hunt?"

### Browse by category
> "Show me top AI tools on Product Hunt this month"

## API

Uses the [Product Hunt API V2](https://api.producthunt.com/v2/docs):
- **GraphQL** endpoint
- **Free** developer token (read-only)
- ~900 requests per 15 minutes
- Access to posts, users, topics, comments, and reviews

## License

MIT
