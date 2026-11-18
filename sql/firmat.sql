-- PikaBlu: firmat elektronike te procesverbali (tablet ose telefon)
-- Ekzekutojeni një herë te Supabase > SQL Editor. Mund të ekzekutohet përsëri pa problem.

alter table public.interventions add column if not exists signatures jsonb;
alter table public.interventions add column if not exists sign_note text;

alter table public.interventions drop constraint if exists interventions_sign_note_check;
alter table public.interventions add constraint interventions_sign_note_check
  check (sign_note is null or sign_note in ('mungonte', 'refuzoi'));

notify pgrst, 'reload schema';
