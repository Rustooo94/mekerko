-- PikaBlu: roli "arketare" (arkëtare) dhe njoftimet e pagesave
--
-- Arkëtarja nuk sheh asgjë nga aplikacioni: as hartën, as pikat, as abonentët, as tubat.
-- Ajo sheh vetëm listën e pagesave të debisë që presin konfirmim dhe shënon
-- "Pagoi" ose "Nuk pagoi". Specialisti që bëri ndërhyrjen merr njoftim në llogarinë e tij.
--
-- Ekzekutojeni një herë te Supabase > SQL Editor. Mund të ekzekutohet përsëri pa problem.

-- 0. Lejo vlerën 'arketare' te kolona role e staff_profiles (ruhen rolet ekzistuese).
do $$
declare def text;
begin
  select pg_get_constraintdef(oid) into def
  from pg_constraint
  where conname = 'staff_profiles_role_check' and conrelid = 'public.staff_profiles'::regclass;
  if def is not null and def not like '%arketare%' then
    execute 'alter table public.staff_profiles drop constraint staff_profiles_role_check';
    execute 'alter table public.staff_profiles add constraint staff_profiles_role_check '
      || replace(def, 'ARRAY[', 'ARRAY[''arketare''::text, ');
  end if;
end $$;

-- 1. A është përdoruesi aktual arkëtare?
create or replace function public.is_arketare()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.staff_profiles
    where user_id = auth.uid() and role = 'arketare'
  );
$$;

-- 2. Bllokim i plotë: arkëtarja nuk lexon, nuk shton, nuk ndryshon dhe nuk fshin
--    në asnjë tabelë të aplikacionit. Punon vetëm me funksionet arka_lista dhe arka_pagesa.
do $$
declare
  t text;
begin
  foreach t in array array['businesses','subscribers','debtors','zones','interventions','defects','complaints','plan_folders','planimetri','abonentet','app_config','uploaders']
  loop
    if to_regclass('public.' || t) is not null then
      execute format('drop policy if exists "arketare pa lexim" on public.%I', t);
      execute format('create policy "arketare pa lexim" on public.%I as restrictive for select to authenticated using (not public.is_arketare())', t);
      execute format('drop policy if exists "arketare pa shtim" on public.%I', t);
      execute format('create policy "arketare pa shtim" on public.%I as restrictive for insert to authenticated with check (not public.is_arketare())', t);
      execute format('drop policy if exists "arketare pa ndryshim" on public.%I', t);
      execute format('create policy "arketare pa ndryshim" on public.%I as restrictive for update to authenticated using (not public.is_arketare())', t);
      execute format('drop policy if exists "arketare pa fshirje" on public.%I', t);
      execute format('create policy "arketare pa fshirje" on public.%I as restrictive for delete to authenticated using (not public.is_arketare())', t);
    end if;
  end loop;
end $$;

-- Te profilet e stafit arkëtarja lexon vetëm profilin e vet.
drop policy if exists "arketare vetem profili im" on public.staff_profiles;
create policy "arketare vetem profili im" on public.staff_profiles as restrictive for select to authenticated
  using (not public.is_arketare() or user_id = auth.uid());
drop policy if exists "arketare pa ndryshim profili" on public.staff_profiles;
create policy "arketare pa ndryshim profili" on public.staff_profiles as restrictive for update to authenticated
  using (not public.is_arketare());

-- Skedarët (foto, video, PDF): asnjë akses për arkëtaren, përveç tutorialit të saj.
drop policy if exists "arketare pa skedare" on storage.objects;
create policy "arketare pa skedare" on storage.objects as restrictive for select to authenticated
  using (not public.is_arketare() or bucket_id = 'tutorialet');
drop policy if exists "arketare pa ngarkim" on storage.objects;
create policy "arketare pa ngarkim" on storage.objects as restrictive for insert to authenticated
  with check (not public.is_arketare());
drop policy if exists "arketare pa ndryshim skedaresh" on storage.objects;
create policy "arketare pa ndryshim skedaresh" on storage.objects as restrictive for update to authenticated
  using (not public.is_arketare());
drop policy if exists "arketare pa fshirje skedaresh" on storage.objects;
create policy "arketare pa fshirje skedaresh" on storage.objects as restrictive for delete to authenticated
  using (not public.is_arketare());

-- 2b. Pagesa e pjesshme: arkëtarja shënon sa fatura ose sa lekë pagoi abonenti.
alter table public.interventions add column if not exists paid_invoices smallint;
alter table public.interventions add column if not exists paid_amount numeric;
alter table public.interventions drop constraint if exists interventions_payment_status_check;
alter table public.interventions add constraint interventions_payment_status_check
  check (payment_status is null or payment_status in ('ne_pritje', 'pagoi', 'pjeserisht', 'nuk_pagoi'));

-- 3. Njoftimet
create table if not exists public.njoftimet (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null,
  title text not null,
  body text,
  intervention_id text,
  created_at timestamptz not null default now(),
  read_at timestamptz
);
create index if not exists njoftimet_user_idx on public.njoftimet (user_id, created_at desc);

alter table public.njoftimet enable row level security;
drop policy if exists "njoftimet e mia" on public.njoftimet;
create policy "njoftimet e mia" on public.njoftimet for select to authenticated using (user_id = auth.uid());
drop policy if exists "njoftimet lexuar" on public.njoftimet;
create policy "njoftimet lexuar" on public.njoftimet for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
-- Njoftimet krijohen vetëm nga funksionet më poshtë, jo nga shfletuesi.

-- Njoftimet mbërrijnë menjëherë (Supabase Realtime).
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'njoftimet') then
    execute 'alter publication supabase_realtime add table public.njoftimet';
  end if;
end $$;

create or replace function public.pb_leke(v numeric)
returns text
language sql
immutable
as $$
  select case when v is null then null
    else regexp_replace(round(v)::bigint::text, '(\d)(?=(\d{3})+$)', '\1 ', 'g') || ' lekë' end;
$$;

-- 3a. Ndërhyrje e re me pagesë "Në pritje": njoftim për çdo arkëtare.
create or replace function public.pb_njofto_arken()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.payment_status = 'ne_pritje' then
    insert into public.njoftimet (user_id, kind, title, body, intervention_id)
    select sp.user_id, 'arka_e_re',
      'Pagesë për t''u kontrolluar: ' || coalesce(nullif(new.subscriber_name, ''), 'abonent pa emër'),
      concat_ws(' · ', new.action,
        case when coalesce(new.contract_no, '') <> '' then 'Kontrata ' || new.contract_no end,
        case when new.debt_amount is not null then 'Debi ' || public.pb_leke(new.debt_amount::numeric) end,
        case when coalesce(new.created_name, '') <> '' then 'Specialisti: ' || new.created_name end),
      new.id::text
    from public.staff_profiles sp
    where sp.role = 'arketare';
  end if;
  return new;
end;
$$;
drop trigger if exists pb_njofto_arken on public.interventions;
create trigger pb_njofto_arken after insert on public.interventions
  for each row execute function public.pb_njofto_arken();

-- 3b. Pagesa u shënua "Pagoi", "Pagoi pjesërisht" ose "Nuk pagoi": njoftim për specialistin.
create or replace function public.pb_njofto_specialistin()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare emri text;
begin
  if (new.payment_status is distinct from old.payment_status
      or new.paid_invoices is distinct from old.paid_invoices
      or new.paid_amount is distinct from old.paid_amount)
     and new.payment_status in ('pagoi', 'pjeserisht', 'nuk_pagoi')
     and new.created_by is not null
     and new.created_by is distinct from auth.uid() then
    emri := coalesce(nullif(new.subscriber_name, ''), 'Abonenti' || case when coalesce(new.contract_no, '') <> '' then ' me kontratë ' || new.contract_no else '' end);
    insert into public.njoftimet (user_id, kind, title, body, intervention_id)
    values (new.created_by,
      new.payment_status,
      case new.payment_status
        when 'pagoi' then emri || ' pagoi të gjithë faturën'
        when 'pjeserisht' then emri || ' pagoi ' || case
          when new.paid_invoices is not null then new.paid_invoices || case when new.paid_invoices = 1 then ' faturë' else ' fatura' end
          when new.paid_amount is not null then public.pb_leke(new.paid_amount)
          else 'pjesërisht' end
        else emri || ' nuk ka paguar pas lajmërimit tuaj' end,
      concat_ws(' · ', new.action || ' më ' || to_char(new.check_date, 'DD.MM.YYYY'),
        case when new.debt_amount is not null then 'Debi ' || public.pb_leke(new.debt_amount::numeric) end,
        case when coalesce(new.payment_by, '') <> '' then 'Konfirmoi ' || new.payment_by end),
      new.id::text);
  end if;
  return new;
end;
$$;
drop trigger if exists pb_njofto_specialistin on public.interventions;
create trigger pb_njofto_specialistin after update of payment_status, paid_invoices, paid_amount on public.interventions
  for each row execute function public.pb_njofto_specialistin();

-- 4. Lista e arkës: vetëm të dhënat që i duhen arkëtares, asgjë tjetër.
--    Pagesat në pritje (pa kufi datash) dhe ato të vendosura në 60 ditët e fundit.
drop function if exists public.arka_lista();
create or replace function public.arka_lista()
returns table (
  id text, check_date date, action text, subscriber_name text, contract_no text,
  debt_amount numeric, specialist text, payment_status text, payment_date date,
  payment_by text, created_at timestamptz, paid_invoices smallint, paid_amount numeric
)
language sql
stable
security definer
set search_path = public
as $$
  select i.id::text, i.check_date, i.action, i.subscriber_name, i.contract_no,
    i.debt_amount::numeric, i.created_name, i.payment_status, i.payment_date,
    i.payment_by, i.created_at, i.paid_invoices, i.paid_amount
  from public.interventions i
  where (public.is_arketare() or exists (select 1 from public.uploaders u where u.user_id = auth.uid()))
    and i.payment_status is not null
    and (i.payment_status = 'ne_pritje' or i.check_date >= current_date - 60 or i.payment_date >= current_date - 60)
  order by (i.payment_status = 'ne_pritje') desc, i.created_at desc
  limit 500;
$$;

-- 5. Konfirmimi nga arka: Pagoi të gjithë, Pagoi pjesërisht (fatura ose lekë), Nuk pagoi ose kthim në pritje.
drop function if exists public.arka_pagesa(text, text);
create or replace function public.arka_pagesa(p_id text, p_status text, p_invoices integer default null, p_amount numeric default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare emri text;
begin
  if not (public.is_arketare() or exists (select 1 from public.uploaders u where u.user_id = auth.uid())) then
    raise exception 'Nuk keni leje për këtë veprim';
  end if;
  if p_status not in ('ne_pritje', 'pagoi', 'pjeserisht', 'nuk_pagoi') then
    raise exception 'Status i panjohur';
  end if;
  if p_status = 'pjeserisht' and not ((p_invoices between 1 and 99) or (p_amount > 0)) then
    raise exception 'Shënoni numrin e faturave ose shumën në lekë';
  end if;
  select full_name into emri from public.staff_profiles where user_id = auth.uid();
  update public.interventions
     set payment_status = p_status,
         payment_date = case when p_status = 'ne_pritje' then null else current_date end,
         payment_by = case when p_status = 'ne_pritje' then null else coalesce(emri, 'Arka') end,
         paid_invoices = case when p_status = 'pjeserisht' and p_invoices between 1 and 99 then p_invoices end,
         paid_amount = case when p_status = 'pjeserisht' and (p_invoices is null or p_invoices not between 1 and 99) and p_amount > 0 then round(p_amount, 2) end
   where id::text = p_id and payment_status is not null;
  if not found then
    raise exception 'Ndërhyrja nuk u gjet';
  end if;
end;
$$;

revoke all on function public.arka_lista() from public, anon;
revoke all on function public.arka_pagesa(text, text, integer, numeric) from public, anon;
grant execute on function public.arka_lista() to authenticated;
grant execute on function public.arka_pagesa(text, text, integer, numeric) to authenticated;

notify pgrst, 'reload schema';

-- 6. Kontroll: bllokimi i arkëtares vlen vetëm për tabelat me RLS aktiv.
--    Në rezultat duhet të shihni "true" te çdo tabelë. Nëse ndonjë del "false", më njoftoni.
select c.relname as tabela, c.relrowsecurity as rls_aktiv
from pg_class c join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind = 'r'
  and c.relname = any (array['businesses','subscribers','debtors','zones','interventions','defects','complaints','plan_folders','planimetri','abonentet','app_config','uploaders','staff_profiles','njoftimet'])
order by 2, 1;

-- 7. Shtimi i një arkëtareje (pasi llogaria është krijuar te Authentication > Users).
--    Zëvendësoni emailin dhe emrin:
-- insert into public.staff_profiles (user_id, full_name, title, sector, role)
-- select id, 'Emri Mbiemri', 'Arkëtare', 'Arka, Njësia Përmet', 'arketare'
-- from auth.users where email = 'emaili@shembull.al';
