-- Run this once in your Supabase project's SQL editor.
-- Dashboard -> SQL Editor -> New query -> paste this -> Run.

-- Profiles: one row per logged-in user, holds their public link slug.
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  display_name text not null,
  slug text unique not null,
  created_at timestamptz default now()
);

-- Messages: anonymous notes sent to a profile. No sender identity is stored.
create table messages (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references profiles(id) on delete cascade not null,
  body text not null check (char_length(body) <= 280),
  nickname text check (char_length(nickname) <= 30),
  created_at timestamptz default now()
);

-- Link opens: one row per time someone opens a /u/[slug] link.
-- referrer_bucket is a coarse category only (e.g. "instagram"), never
-- anything that could identify the individual visitor.
create table link_opens (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references profiles(id) on delete cascade not null,
  referrer_bucket text not null default 'unknown',
  created_at timestamptz default now()
);

-- Row Level Security: each table locked down so only the right people
-- can read or write it.
alter table profiles enable row level security;
alter table messages enable row level security;
alter table link_opens enable row level security;

-- Anyone can look up a profile by slug (needed to render the public send page).
create policy "Public profile lookup by slug"
  on profiles for select
  using (true);

-- Only the owner can create/update their own profile row.
create policy "Users manage their own profile"
  on profiles for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Anyone (including anonymous visitors) can insert a message —
-- that's the whole point of the public send link.
create policy "Anyone can send a message"
  on messages for insert
  with check (true);

-- Only the profile owner can read their messages.
create policy "Owner can read their messages"
  on messages for select
  using (
    profile_id in (select id from profiles where id = auth.uid())
  );

-- Anyone can log a link open (it happens before they're logged in, by definition).
create policy "Anyone can log a link open"
  on link_opens for insert
  with check (true);

-- Only the profile owner can read their own link-open stats.
create policy "Owner can read their link stats"
  on link_opens for select
  using (
    profile_id in (select id from profiles where id = auth.uid())
  );
