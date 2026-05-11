create extension if not exists btree_gist;

create table if not exists public.studycafe_detail (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null unique references public.stores(id) on delete cascade,
  layout_json jsonb not null default '{"seats":[],"elements":[]}'::jsonb,
  usage_options jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.studycafe_reservations (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  user_id text not null,
  seat_id text not null,
  duration_minutes integer not null check (duration_minutes > 0),
  start_at timestamptz not null default now(),
  end_at timestamptz not null,
  status text not null default 'confirmed',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_at > start_at)
);

alter table public.studycafe_reservations
  drop constraint if exists no_overlapping_studycafe_usage;

alter table public.studycafe_reservations
  add constraint no_overlapping_studycafe_usage
  exclude using gist (
    store_id with =,
    seat_id with =,
    tstzrange(start_at, end_at, '[)') with &&
  )
  where (status = 'confirmed');

create table if not exists public.salon_designers (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null,
  introduction text not null default '',
  image_url text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.salon_services (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null,
  description text not null default '',
  duration_minutes integer not null check (duration_minutes > 0),
  price integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.salon_designer_schedules (
  id uuid primary key default gen_random_uuid(),
  designer_id uuid not null references public.salon_designers(id) on delete cascade,
  day_of_week integer not null check (day_of_week between 1 and 7),
  is_working boolean not null default true,
  start_time time not null default '10:00',
  end_time time not null default '19:00',
  slot_minutes integer not null default 30 check (slot_minutes in (30, 60)),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.salon_reservations (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  user_id text not null,
  designer_id uuid not null references public.salon_designers(id) on delete cascade,
  service_id uuid not null references public.salon_services(id) on delete cascade,
  start_at timestamptz not null,
  end_at timestamptz not null,
  status text not null default 'confirmed',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_at > start_at)
);

create unique index if not exists one_salon_customer_per_slot
  on public.salon_reservations (store_id, designer_id, start_at)
  where status in ('pending', 'confirmed');

alter table public.studycafe_detail enable row level security;
alter table public.studycafe_reservations enable row level security;
alter table public.salon_designers enable row level security;
alter table public.salon_services enable row level security;
alter table public.salon_designer_schedules enable row level security;
alter table public.salon_reservations enable row level security;

drop policy if exists "Anyone can read studycafe detail" on public.studycafe_detail;
create policy "Anyone can read studycafe detail"
  on public.studycafe_detail
  for select
  using (true);

drop policy if exists "Anyone can read studycafe reservations" on public.studycafe_reservations;
create policy "Anyone can read studycafe reservations"
  on public.studycafe_reservations
  for select
  using (true);

drop policy if exists "Anyone can read salon designers" on public.salon_designers;
create policy "Anyone can read salon designers"
  on public.salon_designers
  for select
  using (true);

drop policy if exists "Anyone can read salon services" on public.salon_services;
create policy "Anyone can read salon services"
  on public.salon_services
  for select
  using (true);

drop policy if exists "Anyone can read salon schedules" on public.salon_designer_schedules;
create policy "Anyone can read salon schedules"
  on public.salon_designer_schedules
  for select
  using (true);

drop policy if exists "Anyone can read salon reservations" on public.salon_reservations;
create policy "Anyone can read salon reservations"
  on public.salon_reservations
  for select
  using (true);

create or replace function public.start_studycafe_usage(
  p_store_id uuid,
  p_user_id text,
  p_seat_id text,
  p_duration_minutes integer
) returns setof public.studycafe_reservations
language plpgsql
security invoker
as $$
begin
  return query
  insert into public.studycafe_reservations (
    store_id, user_id, seat_id, duration_minutes, start_at, end_at, status
  )
  values (
    p_store_id,
    p_user_id,
    p_seat_id,
    p_duration_minutes,
    now(),
    now() + make_interval(mins => p_duration_minutes),
    'confirmed'
  )
  returning *;
end;
$$;

create or replace function public.extend_studycafe_usage(
  p_reservation_id uuid,
  p_user_id text,
  p_additional_minutes integer
) returns setof public.studycafe_reservations
language plpgsql
security invoker
as $$
begin
  return query
  update public.studycafe_reservations
  set
    duration_minutes = duration_minutes + p_additional_minutes,
    end_at = end_at + make_interval(mins => p_additional_minutes),
    updated_at = now()
  where id = p_reservation_id
    and user_id = p_user_id
    and status = 'confirmed'
    and end_at > now()
  returning *;
end;
$$;

create or replace function public.create_salon_reservation(
  p_store_id uuid,
  p_user_id text,
  p_designer_id uuid,
  p_service_id uuid,
  p_start_at timestamptz
) returns setof public.salon_reservations
language plpgsql
security invoker
as $$
declare
  v_duration_minutes integer;
begin
  select duration_minutes
  into v_duration_minutes
  from public.salon_services
  where id = p_service_id
    and store_id = p_store_id
    and is_active = true;

  if v_duration_minutes is null then
    raise exception 'service not found';
  end if;

  return query
  insert into public.salon_reservations (
    store_id, user_id, designer_id, service_id, start_at, end_at, status
  )
  values (
    p_store_id,
    p_user_id,
    p_designer_id,
    p_service_id,
    p_start_at,
    p_start_at + make_interval(mins => v_duration_minutes),
    'confirmed'
  )
  returning *;
end;
$$;
