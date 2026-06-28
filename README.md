# Anonymous Messages

A small app: you get a personal link, anyone who opens it can send you an
anonymous message (with an optional nickname), and only you can see your
inbox. Your dashboard shows total link opens and a rough breakdown of which
platform people clicked from (Instagram, Facebook, etc.) — never who, just
where.

## What's real here

- Real login (email + password), via Supabase Auth
- Real database (Postgres via Supabase) — messages and clicks persist
- Row-level security so **only you** can ever read your own messages or stats,
  enforced by the database itself, not just by the app's UI
- A public page anyone can open and message you from, no login required
- Live updates — new messages appear in your dashboard without a refresh

## What this can't do

- It can't and won't tell you *who* sent a specific message. The referrer
  bucketing only tells you a platform category in aggregate, never anything
  tied to an individual message.
- The "kindness filter" is a short blocklist, not full moderation. Don't rely
  on it to catch everything.

## Setup (about 15 minutes)

### 1. Create a Supabase project
Go to [supabase.com](https://supabase.com), sign up free, and create a new
project. Wait a minute or two for it to finish provisioning.

### 2. Run the database schema
In your Supabase project: **SQL Editor → New query**. Paste the entire
contents of `supabase-schema.sql` from this project and click **Run**. This
creates your tables and locks them down with row-level security.

### 3. Turn off email confirmation (optional, for faster testing)
**Authentication → Providers → Email** → toggle off "Confirm email." You can
turn this back on later for production use.

### 4. Get your API keys
**Project Settings → API**. Copy the **Project URL** and the **anon public
key**.

### 5. Configure the app
Copy `.env.local.example` to `.env.local` and paste in the two values from
step 4:

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-public-key
```

### 6. Install and run locally
```
npm install
npm run dev
```
Open `http://localhost:3000`, click **Get started**, and create your account.

### 7. Deploy for real (so the link works for anyone, anywhere)
The fastest path is [Vercel](https://vercel.com) (free tier is enough):

1. Push this folder to a GitHub repo
2. Go to vercel.com → **New Project** → import that repo
3. Add the same two environment variables from `.env.local` in Vercel's
   project settings
4. Deploy

You'll get a real URL like `your-app.vercel.app`. Your shareable link will be
`your-app.vercel.app/u/yourname` — that's what you post on Instagram,
Facebook, wherever.

## How the platform tracking actually works

When someone opens `your-app.com/u/yourname`, the server reads the HTTP
`Referer` header (set automatically by the browser when someone clicks a link
from inside the Instagram or Facebook app) and sorts it into a coarse bucket:
Instagram, Facebook, TikTok, Snapchat, Twitter/X, WhatsApp, or Unknown. That
bucket is the only thing stored — never an IP, device ID, or anything that
identifies the visitor.

One real limitation: many apps' in-app browsers strip or rewrite the referrer
header for privacy reasons, so "Unknown" will sometimes legitimately mean "we
don't know," not "something's broken." If you want more reliable bucketing,
share platform-specific links instead, e.g.:
- `your-app.com/u/yourname?ref=instagram` in your Instagram bio
- `your-app.com/u/yourname?ref=facebook` in your Facebook post

The app checks the `ref` query parameter first, before falling back to the
referrer header.
