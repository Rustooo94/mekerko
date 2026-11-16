-- PikaBlu: roli "vezhgues" (vëzhgues)
-- Vëzhguesi lexon të gjitha të dhënat si administratori, por nuk mund të shtojë,
-- ndryshojë ose fshijë asgjë. Ekzekutojeni një herë te Supabase > SQL Editor.
-- Mund të ekzekutohet përsëri pa problem.

-- 1. Funksioni që tregon nëse përdoruesi aktual është vëzhgues
create or replace function public.is_vezhgues()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.staff_profiles
    where user_id = auth.uid() and role = 'vezhgues'
  );
$$;

-- 2. Leje leximi për vëzhguesin dhe bllokim i shkrimit në çdo tabelë të aplikacionit
do $$
declare
  t text;
begin
  foreach t in array array['businesses','subscribers','debtors','zones','interventions','defects','complaints','plan_folders','planimetri']
  loop
    if to_regclass('public.' || t) is not null then
      execute format('drop policy if exists "vezhgues lexon" on public.%I', t);
      execute format('create policy "vezhgues lexon" on public.%I for select to authenticated using (public.is_vezhgues())', t);
      execute format('drop policy if exists "vezhgues pa shtim" on public.%I', t);
      execute format('create policy "vezhgues pa shtim" on public.%I as restrictive for insert to authenticated with check (not public.is_vezhgues())', t);
      execute format('drop policy if exists "vezhgues pa ndryshim" on public.%I', t);
      execute format('create policy "vezhgues pa ndryshim" on public.%I as restrictive for update to authenticated using (not public.is_vezhgues())', t);
      execute format('drop policy if exists "vezhgues pa fshirje" on public.%I', t);
      execute format('create policy "vezhgues pa fshirje" on public.%I as restrictive for delete to authenticated using (not public.is_vezhgues())', t);
    end if;
  end loop;
end $$;

-- 3. Skedarët (foto, video, PDF): lexim po, ngarkim/ndryshim/fshirje jo
drop policy if exists "vezhgues lexon skedaret" on storage.objects;
create policy "vezhgues lexon skedaret" on storage.objects for select to authenticated
  using (bucket_id in ('photos','defektet','ankesat','planimetri') and public.is_vezhgues());
drop policy if exists "vezhgues pa ngarkim" on storage.objects;
create policy "vezhgues pa ngarkim" on storage.objects as restrictive for insert to authenticated
  with check (not public.is_vezhgues());
drop policy if exists "vezhgues pa ndryshim skedaresh" on storage.objects;
create policy "vezhgues pa ndryshim skedaresh" on storage.objects as restrictive for update to authenticated
  using (not public.is_vezhgues());
drop policy if exists "vezhgues pa fshirje skedaresh" on storage.objects;
create policy "vezhgues pa fshirje skedaresh" on storage.objects as restrictive for delete to authenticated
  using (not public.is_vezhgues());

-- 4. Shtimi i një vëzhguesi (pasi llogaria është krijuar te Authentication > Users).
--    Zëvendësoni emailin, emrin dhe titullin:
-- insert into public.staff_profiles (user_id, full_name, title, sector, role)
-- select id, 'Emri Mbiemri', 'Vëzhgues', 'Drejtoria', 'vezhgues'
-- from auth.users where email = 'emaili@shembull.al';
