# appstore-intel

Look up app ratings, reviews, rankings, and metadata for iOS and Android apps. Uses Apple's free iTunes Search & Lookup APIs for iOS and web scraping for Google Play. No API key required.

## Installation

Copy the `appstore-intel` folder into your agent's skills directory.

## Usage Examples

### Look up an app
> "How's the Spotify app rated?"

### Search by category
> "Find the top fitness apps on the App Store"

### Compare apps
> "Compare Notion and Obsidian on the App Store"

## Data Sources

- **iOS / Mac:** [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/) — Free, no authentication, covers App Store and Mac App Store
- **Android:** Google Play Store pages via web scraping — Free, no authentication

## License

MIT
