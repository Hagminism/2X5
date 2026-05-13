create extension if not exists pgcrypto;

create table if not exists public.salon_settings (
  store_id uuid primary key references public.stores(id) on delete cascade,
  slot_minutes integer not null default 30 check (slot_minutes in (30, 60)),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.salon_designers (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null,
  introduction text not null default '',
  image_url text not null default '',
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.salon_designers
  add column if not exists introduction text not null default '',
  add column if not exists image_url text not null default '',
  add column if not exists is_active boolean not null default true,
  add column if not exists sort_order integer not null default 0,
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.salon_services (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null,
  description text not null default '',
  duration_minutes integer not null check (duration_minutes > 0),
  price integer not null default 0 check (price >= 0),
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.salon_services
  add column if not exists description text not null default '',
  add column if not exists duration_minutes integer not null default 30,
  add column if not exists price integer not null default 0,
  add column if not exists is_active boolean not null default true,
  add column if not exists sort_order integer not null default 0,
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.salon_designer_schedules (
  id uuid primary key default gen_random_uuid(),
  designer_id uuid not null references public.salon_designers(id) on delete cascade,
  day_of_week integer not null check (day_of_week between 0 and 6),
  is_working boolean not null default true,
  start_time time not null default '10:00',
  end_time time not null default '19:00',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (designer_id, day_of_week)
);

alter table public.salon_designer_schedules
  add column if not exists is_working boolean not null default true,
  add column if not exists start_time time not null default '10:00',
  add column if not exists end_time time not null default '19:00',
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.salon_reservations (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  user_id text not null references public.users(id),
  designer_id uuid not null references public.salon_designers(id),
  service_id uuid not null references public.salon_services(id),
  start_at timestamptz not null,
  end_at timestamptz not null,
  slot_minutes integer not null check (slot_minutes in (30, 60)),
  status text not null default 'confirmed',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.salon_reservations
  add column if not exists slot_minutes integer not null default 30,
  add column if not exists updated_at timestamptz not null default now();

create unique index if not exists salon_reservations_designer_start_confirmed_idx
  on public.salon_reservations (designer_id, start_at)
  where status = 'confirmed';

create or replace function public.create_salon_reservation(
  p_store_id uuid,
  p_user_id text,
  p_designer_id uuid,
  p_service_id uuid,
  p_start_at timestamptz
)
returns public.salon_reservations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_settings public.salon_settings%rowtype;
  v_designer public.salon_designers%rowtype;
  v_service public.salon_services%rowtype;
  v_schedule public.salon_designer_schedules%rowtype;
  v_local_start timestamp;
  v_local_time time;
  v_day_of_week integer;
  v_minutes_from_midnight integer;
  v_start_minutes integer;
  v_reservation public.salon_reservations%rowtype;
begin
  select *
    into v_settings
    from public.salon_settings
   where store_id = p_store_id;

  if not found then
    v_settings.store_id := p_store_id;
    v_settings.slot_minutes := 30;
  end if;

  select *
    into v_designer
    from public.salon_designers
   where id = p_designer_id
     and store_id = p_store_id
     and is_active = true;

  if not found then
    raise exception 'salon_designer_not_found';
  end if;

  select *
    into v_service
    from public.salon_services
   where id = p_service_id
     and store_id = p_store_id
     and is_active = true;

  if not found then
    raise exception 'salon_service_not_found';
  end if;

  v_local_start := p_start_at at time zone 'Asia/Seoul';
  v_day_of_week := extract(dow from v_local_start)::integer;
  v_local_time := v_local_start::time;

  select *
    into v_schedule
    from public.salon_designer_schedules
   where designer_id = p_designer_id
     and day_of_week = v_day_of_week
     and is_working = true;

  if not found then
    raise exception 'salon_designer_not_working';
  end if;

  if v_local_time < v_schedule.start_time or v_local_time >= v_schedule.end_time then
    raise exception 'salon_start_time_out_of_schedule';
  end if;

  v_minutes_from_midnight :=
    extract(hour from v_local_time)::integer * 60 +
    extract(minute from v_local_time)::integer;
  v_start_minutes :=
    extract(hour from v_schedule.start_time)::integer * 60 +
    extract(minute from v_schedule.start_time)::integer;

  if (v_minutes_from_midnight - v_start_minutes) % v_settings.slot_minutes <> 0 then
    raise exception 'salon_start_time_not_on_slot';
  end if;

  insert into public.salon_reservations (
    store_id,
    user_id,
    designer_id,
    service_id,
    start_at,
    end_at,
    slot_minutes,
    status,
    updated_at
  )
  values (
    p_store_id,
    p_user_id,
    p_designer_id,
    p_service_id,
    p_start_at,
    p_start_at + make_interval(mins => v_service.duration_minutes),
    v_settings.slot_minutes,
    'confirmed',
    now()
  )
  returning * into v_reservation;

  return v_reservation;
exception
  when unique_violation then
    raise exception 'salon_slot_already_reserved';
end;
$$;

alter table public.salon_settings enable row level security;
alter table public.salon_designers enable row level security;
alter table public.salon_services enable row level security;
alter table public.salon_designer_schedules enable row level security;
alter table public.salon_reservations enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'salon_settings'
      and policyname = 'salon settings are publicly readable'
  ) then
    create policy "salon settings are publicly readable"
      on public.salon_settings for select
      using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'salon_designers'
      and policyname = 'salon designers are publicly readable'
  ) then
    create policy "salon designers are publicly readable"
      on public.salon_designers for select
      using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'salon_services'
      and policyname = 'salon services are publicly readable'
  ) then
    create policy "salon services are publicly readable"
      on public.salon_services for select
      using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'salon_designer_schedules'
      and policyname = 'salon designer schedules are publicly readable'
  ) then
    create policy "salon designer schedules are publicly readable"
      on public.salon_designer_schedules for select
      using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'salon_reservations'
      and policyname = 'salon reservations are publicly readable for availability'
  ) then
    create policy "salon reservations are publicly readable for availability"
      on public.salon_reservations for select
      using (true);
  end if;
end $$;
