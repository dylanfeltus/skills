# privacy-cards

Create and manage Privacy.com virtual cards so AI agents can make purchases with controlled spending limits. Single-use cards, merchant-locked cards, spend caps, and transaction monitoring.

## Installation

Copy the `privacy-cards` folder into your agent's skills directory.

## Requirements

- [Privacy.com](https://privacy.com) account with API access
- `PRIVACY_API_KEY` environment variable set
- Free tier: 12 cards/month · Pro ($10/mo): 36 · Premium ($25/mo): 60

## Usage Examples

### Buy a domain
> "Buy example.com on Namecheap. It's $12.99."

The agent creates a single-use card with a $13 limit, completes checkout, and the card auto-closes after one charge.

### Pay for a subscription
> "Sign up for the GitHub Pro plan."

Creates a merchant-locked card that only works at GitHub, with a monthly spend limit matching the plan cost.

### Check recent spending
> "What have my agents spent this month?"

Lists all transactions across cards with amounts, merchants, and statuses.

### Close a card
> "Close the card I made for that Vercel purchase."

Permanently closes the card so no further charges can occur.

## Example Flow

Here's what happens when an agent needs to buy something:

```
User: "Register example.dev on Namecheap"

Agent:
1. Checks Namecheap price → $14.98/yr
2. Creates Privacy.com card:
   - Type: SINGLE_USE
   - Limit: $15.00
   - Memo: "Domain - example.dev via Namecheap"
3. Completes checkout using card details
4. Card auto-closes after the charge
5. Reports back: "Registered example.dev. Charged $14.98 to card ****4142."
```

## Safety

- Agent confirms amount and purpose before creating a card
- `SINGLE_USE` by default (auto-closes after one charge)
- Spend limits set tight to the expected amount
- Full card numbers never shown in chat (last four only)
- Every card gets a descriptive memo for audit trail

## API

Uses the [Privacy.com Developer API](https://privacy-com.readme.io/docs/getting-started):
- RESTful endpoints for card creation, management, and transaction history
- Sandbox environment available for testing
- Works with any agent framework that can make HTTP calls (OpenClaw, Claude Code, Cursor, Codex, custom agents)

## License

MIT
