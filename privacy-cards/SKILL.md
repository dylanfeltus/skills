---
name: privacy-cards
description: Create and manage Privacy.com virtual cards for agent spending. Use when an agent needs to make a purchase, buy a domain, pay for a service, or needs a disposable card with a spending limit. Requires a Privacy.com account and API key.
---

# Privacy.com Virtual Cards

Create, manage, and monitor virtual cards via the Privacy.com API. Designed for AI agents that need to make purchases with controlled spending limits.

## When to Use

- Agent needs to buy something (domain, API access, subscription, physical goods)
- Agent needs a disposable card for a one-time purchase
- User wants to create a spend-limited card for a specific merchant
- User asks to check card status or recent transactions
- User wants to pause or close a card

## Setup

Requires the `PRIVACY_API_KEY` environment variable. Get an API key from your [Privacy.com account settings](https://app.privacy.com/account#api-key).

**Plans and card limits:**
- Free: 12 cards/month
- Pro ($10/mo): 36 cards/month
- Premium ($25/mo): 60 cards/month

**Sandbox:** Use `https://sandbox.privacy.com/v1` for testing. Production: `https://api.privacy.com/v1`.

## API Reference

**Base URL:** `https://api.privacy.com/v1`
**Auth Header:** `Authorization: api-key YOUR_API_KEY`
**Content-Type:** `application/json`

All monetary amounts are in **cents** (e.g., $25.00 = 2500).

### Create a Card

```
POST https://api.privacy.com/v1/cards

{
  "type": "SINGLE_USE",
  "memo": "Domain purchase - example.com",
  "spend_limit": 2500,
  "spend_limit_duration": "TRANSACTION",
  "state": "OPEN"
}
```

**Parameters:**

| Field | Required | Description |
|-------|----------|-------------|
| `type` | Yes | `SINGLE_USE` (auto-closes after one charge), `MERCHANT_LOCKED` (locks to first merchant), `DIGITAL_WALLET` (Apple/Google Pay) |
| `memo` | No | Label for the card (what it's for) |
| `spend_limit` | No | Max spend in cents. Must be whole dollars (e.g., 2500 not 2550) |
| `spend_limit_duration` | No | `TRANSACTION` (per charge), `MONTHLY`, `ANNUALLY`, `FOREVER` |
| `state` | No | `OPEN` (ready to use) or `PAUSED` |
| `exp_month` | No | Two-digit expiry month (auto-generated if omitted) |
| `exp_year` | No | Four-digit expiry year (auto-generated if omitted) |

**Response includes:** `pan` (16-digit card number), `cvv`, `exp_month`, `exp_year`, `token` (card ID), `last_four`.

### Update a Card

```
PATCH https://api.privacy.com/v1/cards/{card_token}

{
  "state": "PAUSED",
  "spend_limit": 5000,
  "memo": "Updated memo"
}
```

Can update: `state`, `memo`, `spend_limit`, `spend_limit_duration`, `funding_token`.

**Setting `state` to `CLOSED` is permanent and cannot be undone.**

### Get Card(s)

```
GET https://api.privacy.com/v1/cards/{card_token}
GET https://api.privacy.com/v1/cards
GET https://api.privacy.com/v1/cards?begin=2024-01-01&end=2024-12-31&page=1&page_size=50
```

**Query parameters:** `begin`, `end` (date filters), `page`, `page_size` (pagination).

### List Transactions

```
GET https://api.privacy.com/v1/transactions?card_token={token}&result=APPROVED&page=1&page_size=50
```

**Query parameters:**

| Field | Description |
|-------|-------------|
| `card_token` | Filter by card |
| `result` | `APPROVED` or decline reason |
| `page` | Page number (1-indexed) |
| `page_size` | Results per page |
| `begin` | Start date (YYYY-MM-DD) |
| `end` | End date (YYYY-MM-DD) |

**Transaction statuses:** `PENDING`, `SETTLING`, `SETTLED`, `VOIDED`, `BOUNCED`, `DECLINED`

## Step-by-Step Instructions

### Creating a Card for an Agent Purchase

1. Determine the amount needed (round up to whole dollars)
2. Choose card type:
   - One-time purchase? Use `SINGLE_USE`
   - Recurring at one merchant (e.g., subscription)? Use `MERCHANT_LOCKED`
3. Create the card and extract only the fields you need. **Never log or print the full API response** — it contains the full card number (PAN) and CVV which must not appear in chat logs or transcripts.

```bash
# Create card and extract only safe fields for logging
RESPONSE=$(curl -s https://api.privacy.com/v1/cards \
  -X POST \
  -H "Authorization: api-key $PRIVACY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "SINGLE_USE",
    "memo": "Purpose of purchase",
    "spend_limit": AMOUNT_IN_CENTS,
    "spend_limit_duration": "TRANSACTION",
    "state": "OPEN"
  }')

# Log only safe fields (no PAN/CVV)
echo "$RESPONSE" | python3 -c "
import sys, json
card = json.load(sys.stdin)
print(json.dumps({
  'token': card.get('token'),
  'last_four': card.get('last_four'),
  'exp_month': card.get('exp_month'),
  'exp_year': card.get('exp_year'),
  'spend_limit': card.get('spend_limit'),
  'state': card.get('state'),
  'memo': card.get('memo')
}, indent=2))
"
```

4. When you need the full card details for checkout, extract them in a **separate step that is not logged to chat**. Use the card details directly in the browser tool or API call without printing them.

```bash
# Extract card details for checkout (DO NOT print to chat)
PAN=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['pan'])")
CVV=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['cvv'])")
EXP_MONTH=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['exp_month'])")
EXP_YEAR=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['exp_year'])")
```

5. Use these card details to complete the purchase (via browser tool or API)
6. After purchase, verify with the transactions endpoint

### Checking a Card's Status

```bash
curl -s https://api.privacy.com/v1/cards/CARD_TOKEN \
  -H "Authorization: api-key $PRIVACY_API_KEY"
```

### Pausing a Card (Temporarily Disable)

```bash
curl -s https://api.privacy.com/v1/cards/CARD_TOKEN \
  -X PATCH \
  -H "Authorization: api-key $PRIVACY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"state": "PAUSED"}'
```

### Closing a Card (Permanent)

```bash
curl -s https://api.privacy.com/v1/cards/CARD_TOKEN \
  -X PATCH \
  -H "Authorization: api-key $PRIVACY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"state": "CLOSED"}'
```

### Viewing Recent Transactions

```bash
curl -s "https://api.privacy.com/v1/transactions?page=1&page_size=10" \
  -H "Authorization: api-key $PRIVACY_API_KEY"
```

## Safety Rules

1. **Always confirm the purchase amount and purpose with the user before creating a card**, unless the user has pre-approved the spend (e.g., "buy this domain" with a known price).
2. **Use `SINGLE_USE` by default.** Only use `MERCHANT_LOCKED` if explicitly needed for recurring charges.
3. **Set the spend limit as close to the expected amount as possible.** Round up to the next whole dollar, but don't over-allocate (e.g., $12.99 item = $13.00 = 1300 cents).
4. **Close or pause cards after use.** `SINGLE_USE` cards auto-close, but `MERCHANT_LOCKED` cards stay open. Close them when no longer needed.
5. **Never log, print, or display the full PAN or CVV in chat, logs, or tool output.** The raw API response contains sensitive card data (PAN, CVV) that must not appear in transcripts. Always parse the response and extract only safe fields (token, last_four, memo, spend_limit, state) for logging. Use full card details only in the checkout step, never echoed to chat.
6. **Include a descriptive memo** on every card so the user can identify what it was for in their Privacy.com dashboard.

## Output Format

When creating a card, report to the user:

```
Created Privacy.com card (****1234)
Type: Single-use
Limit: $25.00
Memo: Domain purchase - example.com
Status: Ready to use
```

When listing transactions:

```
Recent transactions:

1. $12.99 at NAMECHEAP.COM - SETTLED (Jan 15, 2024)
   Card: ****1234 (Domain purchase)

2. $49.00 at GITHUB.COM - PENDING (Jan 14, 2024)
   Card: ****5678 (GitHub Pro subscription)
```

## Error Handling

- **401 Unauthorized:** API key is invalid or missing. Check `PRIVACY_API_KEY` env var.
- **403 Forbidden:** Account may need verification or doesn't have API access.
- **429 Rate Limited:** Back off and retry after a short delay.
- **Card creation fails:** May have hit the monthly card limit for the plan tier. Inform the user.
- **Amount not in whole dollars:** The API requires spend_limit in whole-dollar increments (in cents). Round up.

## Sandbox Testing

For testing without real money, use the sandbox environment:

- **Base URL:** `https://sandbox.privacy.com/v1`
- **Simulate transactions:** `POST https://sandbox.privacy.com/v1/simulate/authorize` and `POST https://sandbox.privacy.com/v1/simulate/clearing`
- Sandbox cards work identically to production but no real charges occur.

## Data Source

[Privacy.com Developer API](https://privacy-com.readme.io/docs/getting-started) - RESTful API, requires API key from a Privacy.com account.
