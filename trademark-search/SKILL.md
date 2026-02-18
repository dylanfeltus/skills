# USPTO Trademark Search

Search the United States Patent and Trademark Office (USPTO) database to check trademark availability and get registration details. Uses a combination of the USPTO's TSDR API and web search for comprehensive results.

## When to Use

- User wants to check if a name/brand is trademarked
- User is researching trademark availability before naming a product
- User wants details on an existing trademark registration
- User asks "is [name] trademarked?" or "can I use [name]?"

## Important Disclaimer

**This skill provides informational data only — not legal advice.** Always recommend the user consult a trademark attorney for definitive guidance. Trademark availability depends on many factors beyond exact-match searches (similarity, likelihood of confusion, goods/services classes, etc.).

## Approach

There is no free public full-text trademark search API. The strategy is:

1. **Web search** for initial trademark discovery (fast, broad)
2. **USPTO Trademark Search** (tmsearch.uspto.gov) for official records via web scraping
3. **TSDR API** for detailed status on known serial/registration numbers (requires free API key)

## Step 1: Web Search for Trademark Info

Use `web_search` to quickly check if a name has trademark registrations:

```
web_search: "BRAND_NAME" trademark USPTO site:uspto.gov
```

Also search more broadly:

```
web_search: "BRAND_NAME" trademark registered
```

```
web_search: "BRAND_NAME" site:trademarkia.com
```

```
web_search: "BRAND_NAME" site:tmdn.org
```

### What to Look For

- Results from `tsdr.uspto.gov` or `tmsearch.uspto.gov` → existing trademark record
- Results from `trademarkia.com` → trademark database with status info
- Company websites claiming "® " or "™" → claimed/registered marks
- The Nice Classification class for goods/services

## Step 2: USPTO Trademark Search (tmsearch.uspto.gov)

The new USPTO trademark search system is at `https://tmsearch.uspto.gov/`.

To search it programmatically, try fetching search results:

```
web_fetch: https://tmsearch.uspto.gov/search/search-results?query=BRAND_NAME&section=all
```

If the page is JS-rendered and doesn't return useful content, fall back to web search with:

```
web_search: site:tmsearch.uspto.gov "BRAND_NAME"
```

## Step 3: TSDR API for Status Details

Once you have a **serial number** or **registration number** from Step 1 or 2, use the TSDR API for detailed status.

### TSDR Status API

```
web_fetch: https://tsdr.uspto.gov/statusview/sn{SERIAL_NUMBER}
```

Or by registration number:

```
web_fetch: https://tsdr.uspto.gov/statusview/rn{REGISTRATION_NUMBER}
```

### TSDR XML Data (if API key available)

```bash
curl -s "https://tsdr.uspto.gov/documentviewer/sn{SERIAL_NUMBER}/XML" \
  -H "USPTO-API-KEY: $USPTO_API_KEY"
```

### Key Status Values

| Status | Meaning |
|--------|---------|
| **LIVE** | Active trademark — registered or pending |
| **DEAD** | Abandoned, cancelled, or expired |
| **Registered** | Fully registered and active |
| **Published for Opposition** | Pending — 30-day window for objections |
| **Abandoned** | Application was abandoned |
| **Cancelled** | Registration was cancelled |
| **Expired** | Registration expired (not renewed) |

## Step 4: Check Third-Party Databases

For more comprehensive searching, also check:

### Trademarkia

```
web_fetch: https://www.trademarkia.com/trademarks-search.aspx?tn=BRAND_NAME
```

Trademarkia provides a user-friendly view of USPTO records plus international marks.

### WIPO Global Brand Database (International)

```
web_search: "BRAND_NAME" site:branddb.wipo.int
```

Or direct search:

```
web_fetch: https://branddb.wipo.int/branddb/en/#tabs_1_2
```

## Trademark Classes (Nice Classification)

When reporting results, include the goods/services class:

| Class | Category |
|-------|----------|
| 9 | Software, apps, electronics |
| 25 | Clothing, footwear |
| 35 | Advertising, business management |
| 41 | Education, entertainment |
| 42 | Software design, SaaS, tech services |

A trademark only protects within its registered class(es). A name can be registered by different entities in different classes.

## Output Format

### Availability Check

```
### Trademark Search: "BRAND NAME"

**⚠️ Disclaimer:** This is an informational search only, not legal advice. Consult a trademark attorney before making business decisions.

#### Findings

**Exact Matches Found:** Yes/No

1. **BRAND NAME** — Registration #1234567
   Status: 🟢 LIVE / Registered
   Owner: Company Name, Inc.
   Filed: Jan 15, 2020 · Registered: Aug 3, 2020
   Class: 9 (Software), 42 (SaaS)
   Goods/Services: "Computer software for project management..."
   🔗 https://tsdr.uspto.gov/statusview/rn1234567

2. **BRAND NAME** — Serial #90123456
   Status: 🔴 DEAD / Abandoned
   Owner: Other Company LLC
   Filed: Mar 1, 2019 · Abandoned: Sep 15, 2019
   Class: 35 (Business services)

#### Similar Marks Found
- BRAND NAYME — Reg #2345678 (Class 9, LIVE)
- BRANDNAME — Reg #3456789 (Class 42, LIVE)

#### Assessment
- [Summary of what was found]
- [Note relevant classes vs user's intended use]
- [Recommend next steps]
```

### Quick Check

```
### Trademark: "BRAND NAME"

✅ No exact matches found in USPTO database.
⚠️ Similar marks exist: [list]
📋 Recommended classes to check: 9, 42 (if software)

**Next steps:** Consider a comprehensive search with a trademark attorney before filing.
```

## Error Handling

- **No results from web search:** This doesn't mean the name is available — it may not be indexed yet. Note this uncertainty.
- **TSDR page unavailable:** The USPTO site has maintenance windows (usually weekends). Try again later.
- **JS-rendered pages:** Fall back to `web_search` with `site:` prefixes.
- **API key missing:** Skip the TSDR XML endpoint. The web-based status view and web search provide sufficient information for most queries.

## Important Caveats to Always Mention

1. **Common law trademarks** exist without registration — a name can be "taken" even if not in the USPTO database
2. **State registrations** are separate from federal (USPTO) registrations
3. **International marks** may conflict — check WIPO if relevant
4. **Likelihood of confusion** matters — similar (not just identical) marks can conflict
5. **Class matters** — same name can coexist in different goods/services classes
6. **This is not legal advice** — always recommend consulting a trademark attorney

## Examples

### Example 1: "Is 'Stellar' trademarked?"

1. `web_search: "Stellar" trademark USPTO`
2. `web_search: "Stellar" site:trademarkia.com`
3. Review results, find serial/registration numbers
4. Look up status via TSDR for each match
5. Present findings with class info and assessment

### Example 2: "Can I use 'NovaPay' for a fintech app?"

1. `web_search: "NovaPay" trademark`
2. `web_search: "NovaPay" site:trademarkia.com`
3. Check for marks in Class 9 (software) and Class 36 (financial services)
4. Present findings and note relevant classes for fintech

### Example 3: "Check trademark status for registration number 5678901"

1. `web_fetch: https://tsdr.uspto.gov/statusview/rn5678901`
2. Present the current status, owner, and class information

## Data Sources

- **USPTO Trademark Search:** [tmsearch.uspto.gov](https://tmsearch.uspto.gov/) — Official US trademark database
- **USPTO TSDR:** [tsdr.uspto.gov](https://tsdr.uspto.gov/) — Status and document retrieval
- **Trademarkia:** [trademarkia.com](https://www.trademarkia.com/) — User-friendly trademark search
- **WIPO Global Brand Database:** [branddb.wipo.int](https://branddb.wipo.int/) — International trademarks
