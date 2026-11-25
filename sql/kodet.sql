-- PikaBlu: kodi i pikës, p.sh. PB-Kinemaja-0001
-- Çdo zonë (lagje ose fshat) numëron nga 0001. Kodi është unik në gjithë sistemin,
-- pa dallim shkronjash të mëdha ose të vogla.
-- Ekzekutojeni një herë te Supabase > SQL Editor. Mund të ekzekutohet përsëri pa problem.

alter table public.businesses add column if not exists code text;

create unique index if not exists businesses_code_unique
  on public.businesses (upper(code))
  where code is not null and code <> '';

notify pgrst, 'reload schema';
