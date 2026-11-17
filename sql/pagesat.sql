-- PikaBlu: statusi i pagesës te ndërhyrjet (Në pritje / Pagoi / Nuk pagoi)
-- Ekzekutojeni një herë te Supabase > SQL Editor. Mund të ekzekutohet përsëri pa problem.

alter table public.interventions add column if not exists payment_status text;
alter table public.interventions add column if not exists payment_date date;
alter table public.interventions add column if not exists payment_by text;

alter table public.interventions drop constraint if exists interventions_payment_status_check;
alter table public.interventions add constraint interventions_payment_status_check
  check (payment_status is null or payment_status in ('ne_pritje', 'pagoi', 'nuk_pagoi'));

create index if not exists interventions_payment_idx on public.interventions (payment_status);

-- Konfirmimi i pagesës: e bën ai që e regjistroi ndërhyrjen ose administratori.
drop policy if exists "ndryshim i pageses" on public.interventions;
create policy "ndryshim i pageses" on public.interventions for update to authenticated
  using (created_by = auth.uid() or exists (select 1 from public.uploaders u where u.user_id = auth.uid()))
  with check (created_by = auth.uid() or exists (select 1 from public.uploaders u where u.user_id = auth.uid()));

notify pgrst, 'reload schema';
