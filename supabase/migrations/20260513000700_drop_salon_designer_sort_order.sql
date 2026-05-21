drop index if exists public.salon_designers_store_deleted_sort_idx;

alter table public.salon_designers
  drop column if exists sort_order;

create index if not exists salon_designers_store_deleted_created_idx
  on public.salon_designers (store_id, is_deleted, created_at, id);
