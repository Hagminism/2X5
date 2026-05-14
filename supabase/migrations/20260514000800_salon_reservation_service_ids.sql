revoke execute on function public.create_salon_reservation(
  uuid,
  text,
  uuid,
  uuid,
  timestamptz
) from public;

drop function if exists public.create_salon_reservation(
  uuid,
  text,
  uuid,
  uuid,
  timestamptz
);

alter table public.salon_reservations
  add column if not exists service_ids uuid[];

update public.salon_reservations
   set service_ids = array[service_id]
 where service_ids is null
   and service_id is not null;

alter table public.salon_reservations
  alter column service_ids set not null;

drop index if exists public.salon_reservations_service_id_idx;

alter table public.salon_reservations
  drop column if exists service_id;

create or replace function public.create_salon_reservation(
  p_store_id uuid,
  p_user_id text,
  p_designer_id uuid,
  p_service_ids uuid[],
  p_start_at timestamptz
)
returns public.salon_reservations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_slot_minutes integer;
  v_designer public.salon_designers%rowtype;
  v_service_count integer;
  v_total_minutes integer;
  v_schedule public.salon_designer_schedules%rowtype;
  v_local_start timestamp;
  v_local_end timestamp;
  v_local_time time;
  v_day_of_week integer;
  v_minutes_from_midnight integer;
  v_start_minutes integer;
  v_reservation public.salon_reservations%rowtype;
begin
  if p_service_ids is null or cardinality(p_service_ids) = 0 then
    raise exception 'salon_service_not_found';
  end if;

  select count(*)::integer
    into v_service_count
    from unnest(p_service_ids) as sid
   where exists (
     select 1
       from public.salon_services s
      where s.id = sid
        and s.store_id = p_store_id
        and s.is_active = true
   );

  if v_service_count <> cardinality(p_service_ids) then
    raise exception 'salon_service_not_found';
  end if;

  select coalesce(sum(s.duration_minutes), 0)::integer
    into v_total_minutes
    from public.salon_services s
   where s.id = any(p_service_ids)
     and s.store_id = p_store_id
     and s.is_active = true;

  if v_total_minutes <= 0 then
    raise exception 'salon_service_not_found';
  end if;

  select reservation_slot_minutes
    into v_slot_minutes
    from public.stores
   where id = p_store_id;

  if not found then
    raise exception 'store_not_found';
  end if;

  select *
    into v_designer
    from public.salon_designers
   where id = p_designer_id
     and store_id = p_store_id
     and is_active = true
     and is_deleted = false;

  if not found then
    raise exception 'salon_designer_not_found';
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

  if (v_minutes_from_midnight - v_start_minutes) % v_slot_minutes <> 0 then
    raise exception 'salon_start_time_not_on_slot';
  end if;

  v_local_end := (p_start_at + make_interval(mins => v_total_minutes))
    at time zone 'Asia/Seoul';

  if v_local_end::date <> v_local_start::date
     or v_local_end::time > v_schedule.end_time then
    raise exception 'salon_end_time_out_of_schedule';
  end if;

  insert into public.salon_reservations (
    store_id,
    user_id,
    designer_id,
    service_ids,
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
    p_service_ids,
    p_start_at,
    p_start_at + make_interval(mins => v_total_minutes),
    v_slot_minutes,
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

revoke execute on function public.create_salon_reservation(
  uuid,
  text,
  uuid,
  uuid[],
  timestamptz
) from public;

grant execute on function public.create_salon_reservation(
  uuid,
  text,
  uuid,
  uuid[],
  timestamptz
) to service_role;
