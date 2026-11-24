-- PikaBlu: numri i kateve për pallatet
-- Ekzekutojeni një herë te Supabase > SQL Editor. Mund të ekzekutohet përsëri pa problem.

alter table public.businesses add column if not exists floors smallint;

alter table public.businesses drop constraint if exists businesses_floors_check;
alter table public.businesses add constraint businesses_floors_check
  check (floors is null or floors between 1 and 40);

notify pgrst, 'reload schema';
