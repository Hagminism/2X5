create index if not exists salon_designers_store_id_idx
  on public.salon_designers (store_id);

create index if not exists salon_services_store_id_idx
  on public.salon_services (store_id);

create index if not exists salon_reservations_store_id_idx
  on public.salon_reservations (store_id);

create index if not exists salon_reservations_user_id_idx
  on public.salon_reservations (user_id);

create index if not exists salon_reservations_service_id_idx
  on public.salon_reservations (service_id);

revoke execute on function public.create_salon_reservation(
  uuid,
  text,
  uuid,
  uuid,
  timestamptz
) from anon, authenticated;

grant execute on function public.create_salon_reservation(
  uuid,
  text,
  uuid,
  uuid,
  timestamptz
) to service_role;
