revoke execute on function public.create_salon_reservation(
  uuid,
  text,
  uuid,
  uuid,
  timestamptz
) from public;

grant execute on function public.create_salon_reservation(
  uuid,
  text,
  uuid,
  uuid,
  timestamptz
) to service_role;
