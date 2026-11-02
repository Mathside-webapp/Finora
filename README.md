# Finora — Financial Command Center

A glassmorphism personal finance PWA built with vanilla HTML/CSS/JavaScript and Supabase. This is a functional **starter implementation**, not a production-certified banking or accounting system.

## Quick start
1. Create a Supabase project. Open SQL Editor and run `supabase/migrations/202611020001_initial.sql`.
2. In Supabase Authentication > URL Configuration, add your local origin (for example `http://localhost:8000`) and deployed URL as allowed redirect URLs. Configure email confirmation and recovery templates.
3. Edit `js/config.js` with your **project URL** and **publishable key**. NEVER use a secret or service-role key in the browser.
4. From the Finora directory run `python -m http.server 8000` and open `http://localhost:8000`. Sign up and confirm email, then sign in.
5. Choose a unique offline vault passphrase (8+ characters). The vault is encrypted with AES-GCM and PBKDF2-derived keys. The passphrase is not stored. Losing it means losing access to the device's offline copy, though cloud data can be recovered with account access and a newly initialized vault.
6. Optionally deploy the authenticated sample Edge Function: `supabase functions deploy health-check` after `supabase login` and `supabase link --project-ref YOUR_PROJECT_REF`.
7. Deploy the static directory to any HTTPS static host. PWA installation requires HTTPS (except localhost). Service worker caches same-origin assets.

## Main modules
Overview, transactions, accounts, budgets, borrower loans and repayments, own loans and repayments, bills and bill payments, credit cards, CSV export, browser print/PDF, encrypted JSON backup and merge restore. Sample data is only accessible via a clearly marked isolated demo mode.

## Finance rules
- Monetary amounts are stored as **integer minor units** (e.g. 1250 for ₱12.50), avoiding binary floating-point accounting operations for addition and subtraction.
- Cash account balance = opening balance + ordinary income - ordinary expenses + incoming transfers - outgoing transfers - receivable disbursements + receivable collections + debt proceeds - debt payments - bill payments - credit card payments.
- Borrower principal repayments reduce receivables; interest collected is income. Own loan principal reduces debt; loan interest is an expense. Credit card purchases are expenses when recorded, repayments reduce cash and credit liability and are not expenses again.
- Account transfers are never income or expenses. Opening balances are not income. Date filtering is based on Asia/Manila dates as entered.
- Changing display currency only changes formatting; **no FX conversion occurs**. Keep all amounts in one chosen currency per user.

## Security and sync notes
- RLS is enforced on all rows in the `finance_records` table. The browser uses only a public publishable key. Each document includes user_id, id, kind; the database checks them.
- Offline vault is encrypted in IndexedDB. The session token itself is managed by Supabase and is not part of the encrypted vault.
- Offline writes queue locally and synchronize on reconnect. Conflict strategy: queued local changes take priority over downloaded versions; otherwise the latest server timestamp is used. **This is not a multi-device transactional ledger** and simultaneous editing across devices may overwrite records.
- Browser-local storage and exports are sensitive; use strong passwords, secure devices, and trusted HTTPS hosts.
- Encrypted backup restoration merges by record UUID. It does not overwrite other users' records because imported rows are assigned to the signed-in user. Validate your backup before importing.

## Important limitations before production use
This v1 is a substantial prototype, but **does not yet implement** server-side atomic double-entry posting, immutable ledger events, full recurring bill generation, amortization schedules, scheduled notifications, automatic email reminders, accurate statement-cycle calculations, or true multi-currency accounting. In-app due reminders are calculated when the app is open. Manual backup exists, but there is no automated database backup schedule. A fresh browser/device needs network authentication before first use. The Supabase SDK and Google Fonts load from external CDNs and require internet at least once. The PWA manifest uses SVG icons; some platforms prefer PNG variants. Avoid using this for high-stakes accounting until financial invariants, database-level validation, and integration tests are completed.

## Official documentation reviewed
- https://supabase.com/docs/guides/auth
- https://supabase.com/docs/reference/javascript/auth-getuser
- https://supabase.com/docs/guides/functions/auth
- https://supabase.com/docs/guides/auth/choosing-a-server-package

## Development testing
Run `node tests/money.test.mjs` and `node --check js/app.js`. Supabase integration and mobile/browser installation tests require your deployed project and supported browser.


## Email/password accounts (v4)
Anonymous sign-in and guest demo access have been removed. Enable Email provider and allow new user registrations in Supabase Authentication. Keep Anonymous disabled. Run both SQL migrations in order, including `202611020002_profiles.sql`. Configure `js/config.js` with your Supabase URL and publishable key (never service-role key). Users register using the Create account button, confirm their email if confirmation is enabled, and sign in. Previously registered users are backfilled into profiles. Offline access requires a previously authenticated session and vault passphrase.
