-- Contacto de emergencia (un registro por usuario).
create table if not exists public.emergency_contacts (
  user_id uuid primary key references auth.users (id) on delete cascade,
  name text not null default '',
  phone text not null default '',
  updated_at timestamptz not null default now()
);

alter table public.emergency_contacts enable row level security;

create policy "emergency_contacts_select_own"
  on public.emergency_contacts for select
  using (auth.uid() = user_id);

create policy "emergency_contacts_insert_own"
  on public.emergency_contacts for insert
  with check (auth.uid() = user_id);

create policy "emergency_contacts_update_own"
  on public.emergency_contacts for update
  using (auth.uid() = user_id);

-- Movimientos / actividad por hora (aperturas, rutas, alertas, etc.).
create table if not exists public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  activity_type text not null,
  recorded_at timestamptz not null default now(),
  details jsonb
);

alter table public.activity_logs enable row level security;

create policy "activity_logs_select_own"
  on public.activity_logs for select
  using (auth.uid() = user_id);

create policy "activity_logs_insert_own"
  on public.activity_logs for insert
  with check (auth.uid() = user_id);

create index if not exists activity_logs_user_time_idx
  on public.activity_logs (user_id, recorded_at desc);
