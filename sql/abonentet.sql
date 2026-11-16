-- PikaBlu: regjistri i abonentëve (lista nga Excel sipas fshatit)
-- Ekzekutojeni një herë te Supabase > SQL Editor. Mund të ekzekutohet përsëri pa problem.

create table if not exists public.abonentet (
  id bigint generated always as identity primary key,
  full_name text not null,
  first_name text,
  last_name text,
  contract_no text,
  zone_id bigint,
  zone_name text,
  batch text,
  created_at timestamptz not null default now()
);
create index if not exists abonentet_zone_idx on public.abonentet (zone_id);
create index if not exists abonentet_contract_idx on public.abonentet (contract_no);

alter table public.abonentet enable row level security;

-- Leximi: çdo punonjës me llogari (për plotësimin automatik). Qytetarët pa llogari nuk shohin asgjë.
drop policy if exists "abonentet lexim" on public.abonentet;
create policy "abonentet lexim" on public.abonentet for select to authenticated using (true);

-- Shtimi, ndryshimi dhe fshirja: vetëm administratori (tabela uploaders).
drop policy if exists "abonentet shtim" on public.abonentet;
create policy "abonentet shtim" on public.abonentet for insert to authenticated
  with check (exists (select 1 from public.uploaders u where u.user_id = auth.uid()));
drop policy if exists "abonentet ndryshim" on public.abonentet;
create policy "abonentet ndryshim" on public.abonentet for update to authenticated
  using (exists (select 1 from public.uploaders u where u.user_id = auth.uid()));
drop policy if exists "abonentet fshirje" on public.abonentet;
create policy "abonentet fshirje" on public.abonentet for delete to authenticated
  using (exists (select 1 from public.uploaders u where u.user_id = auth.uid()));
