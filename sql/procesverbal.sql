-- PikaBlu: procesverbali i ndërhyrjes (vula e vjetër, vula e re, foto e dytë)
-- Ekzekutojeni një herë te Supabase > SQL Editor. Mund të ekzekutohet përsëri pa problem.

alter table public.interventions add column if not exists old_seal text;
alter table public.interventions add column if not exists new_seal text;
alter table public.interventions add column if not exists photo_path2 text;

notify pgrst, 'reload schema';
