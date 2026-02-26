## Review guidelines

- No hardcoded API keys, secrets, or tokens
- No `console.log` in production code (use proper logging or remove)
- No `any` types in TypeScript — use proper types
- All API routes must have error handling (try/catch, proper status codes)
- Database queries must handle errors gracefully
- No TODO comments without context or linked issues
- Verify env vars are documented if new ones are added
- Check for SQL injection / unsanitized user input
- No secrets or PII in comments or variable names
- Imports should be used — flag dead imports
- Functions over 50 lines should be flagged for refactoring consideration
