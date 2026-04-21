-- Eye Alert — run in Supabase SQL editor (or supabase db push).
-- Aligns with Flutter client: driving_sessions, app_daily_usage, events with user_id.

-- Daily app opens (one row per user per calendar day in UTC; adjust if you need local TZ).
create table if not exists public.app_daily_usage (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  usage_date date not null,
  first_open_at timestamptz not null default now(),
  last_open_at timestamptz not null default now(),
  open_count int not null default 1,
  unique (user_id, usage_date)
);

alter table public.app_daily_usage enable row level security;

create policy "app_daily_usage_select_own"
  on public.app_daily_usage for select
  using (auth.uid() = user_id);

create policy "app_daily_usage_insert_own"
  on public.app_daily_usage for insert
  with check (auth.uid() = user_id);

create policy "app_daily_usage_update_own"
  on public.app_daily_usage for update
  using (auth.uid() = user_id);

-- Driving session summary (somnolence aggregates per trip).
create table if not exists public.driving_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  duration_seconds int,
  max_level text,
  sec_normal int not null default 0,
  sec_tired int not null default 0,
  sec_drowsy int not null default 0,
  sec_critical int not null default 0,
  critical_events int not null default 0
);

alter table public.driving_sessions enable row level security;

create policy "driving_sessions_select_own"
  on public.driving_sessions for select
  using (auth.uid() = user_id);

create policy "driving_sessions_insert_own"
  on public.driving_sessions for insert
  with check (auth.uid() = user_id);

create policy "driving_sessions_update_own"
  on public.driving_sessions for update
  using (auth.uid() = user_id);

-- Optional: fine-grained samples (client throttles inserts).
create table if not exists public.drowsiness_samples (
  id bigserial primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  session_id uuid references public.driving_sessions (id) on delete cascade,
  recorded_at timestamptz not null default now(),
  level text not null,
  eye_closure_sec double precision not null default 0
);

alter table public.drowsiness_samples enable row level security;

create policy "drowsiness_samples_select_own"
  on public.drowsiness_samples for select
  using (auth.uid() = user_id);

create policy "drowsiness_samples_insert_own"
  on public.drowsiness_samples for insert
  with check (auth.uid() = user_id);

-- Events table: ensure user_id column exists for RLS and analytics.
-- If you already have `events`, add the column + policies instead of creating.
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  type text not null,
  latitude double precision not null,
  longitude double precision not null,
  severity text not null,
  created_at timestamptz not null default now()
);

alter table public.events enable row level security;

-- If table existed without user_id, run manually:
-- alter table public.events add column if not exists user_id uuid references auth.users (id);

drop policy if exists "events_select_own" on public.events;
create policy "events_select_own"
  on public.events for select
  using (auth.uid() = user_id);

drop policy if exists "events_insert_own" on public.events;
create policy "events_insert_own"
  on public.events for insert
  with check (auth.uid() = user_id);

create index if not exists events_user_created_idx on public.events (user_id, created_at desc);
create index if not exists app_daily_usage_user_date_idx on public.app_daily_usage (user_id, usage_date desc);
create index if not exists driving_sessions_user_started_idx on public.driving_sessions (user_id, started_at desc);
