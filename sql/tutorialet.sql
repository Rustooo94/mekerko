-- PikaBlu: tutorialet me video për çdo rol
-- Videot ruhen në dosjen private "tutorialet" te Supabase Storage, jo në GitHub.
-- I shohin vetëm përdoruesit e kyçur; i ngarkon dhe i zëvendëson vetëm administratori.
-- Ekzekutojeni një herë te Supabase > SQL Editor. Mund të ekzekutohet përsëri pa problem.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('tutorialet', 'tutorialet', false, 52428800, array['video/mp4'])
on conflict (id) do update set public = false, file_size_limit = 52428800, allowed_mime_types = array['video/mp4'];

drop policy if exists "tutorialet lexim" on storage.objects;
create policy "tutorialet lexim" on storage.objects for select to authenticated
  using (bucket_id = 'tutorialet');

drop policy if exists "tutorialet ngarkim" on storage.objects;
create policy "tutorialet ngarkim" on storage.objects for insert to authenticated
  with check (bucket_id = 'tutorialet' and exists (select 1 from public.uploaders u where u.user_id = auth.uid()));

drop policy if exists "tutorialet ndryshim" on storage.objects;
create policy "tutorialet ndryshim" on storage.objects for update to authenticated
  using (bucket_id = 'tutorialet' and exists (select 1 from public.uploaders u where u.user_id = auth.uid()))
  with check (bucket_id = 'tutorialet' and exists (select 1 from public.uploaders u where u.user_id = auth.uid()));

drop policy if exists "tutorialet fshirje" on storage.objects;
create policy "tutorialet fshirje" on storage.objects for delete to authenticated
  using (bucket_id = 'tutorialet' and exists (select 1 from public.uploaders u where u.user_id = auth.uid()));

-- Arkëtarja nuk sheh asnjë skedar tjetër, por tutorialin e vet e sheh.
do $$
begin
  if to_regprocedure('public.is_arketare()') is not null then
    execute 'drop policy if exists "arketare pa skedare" on storage.objects';
    execute 'create policy "arketare pa skedare" on storage.objects as restrictive for select to authenticated '
      || 'using (not public.is_arketare() or bucket_id = ''tutorialet'')';
  end if;
end $$;
