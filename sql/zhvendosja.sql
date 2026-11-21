-- PikaBlu: zhvendosja e një pike nga administratori
-- Administratori (tabela uploaders) mund të zhvendosë çdo pikë në hartë, edhe ato të shtuara nga të tjerët.
-- Çdo zhvendosje ruhet te tabela zhvendosjet: kush e bëri, kur, nga ku dhe ku.
-- Vëzhguesi dhe arkëtarja nuk mund ta bëjnë.
-- Ekzekutojeni një herë te Supabase > SQL Editor. Mund të ekzekutohet përsëri pa problem.

create table if not exists public.zhvendosjet (
  id bigint generated always as identity primary key,
  point_id text not null,
  point_name text,
  old_lat double precision,
  old_lng double precision,
  new_lat double precision,
  new_lng double precision,
  distance_m integer,
  moved_by uuid default auth.uid(),
  moved_name text,
  moved_at timestamptz not null default now()
);
alter table public.zhvendosjet enable row level security;
drop policy if exists "zhvendosjet lexim" on public.zhvendosjet;
create policy "zhvendosjet lexim" on public.zhvendosjet for select to authenticated
  using (exists (select 1 from public.uploaders u where u.user_id = auth.uid())
      or exists (select 1 from public.staff_profiles s where s.user_id = auth.uid() and s.role = 'vezhgues'));
-- Regjistrimet shtohen vetëm nga funksioni më poshtë.

create or replace function public.zhvendos_piken(p_id text, p_lat double precision, p_lng double precision)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  o_lat double precision; o_lng double precision; o_name text; emri text;
begin
  if not exists (select 1 from public.uploaders u where u.user_id = auth.uid())
     or exists (select 1 from public.staff_profiles s where s.user_id = auth.uid() and s.role in ('vezhgues', 'arketare')) then
    raise exception 'Vetëm administratori mund ta zhvendosë pikën';
  end if;
  if p_lat is null or p_lng is null or p_lat not between 39 and 43 or p_lng not between 18.5 and 21.5 then
    raise exception 'Koordinatat janë jashtë Shqipërisë';
  end if;
  select lat, lng, name into o_lat, o_lng, o_name from public.businesses where id::text = p_id;
  if not found then
    raise exception 'Pika nuk u gjet';
  end if;
  update public.businesses set lat = p_lat, lng = p_lng where id::text = p_id;
  select full_name into emri from public.staff_profiles where user_id = auth.uid();
  insert into public.zhvendosjet (point_id, point_name, old_lat, old_lng, new_lat, new_lng, distance_m, moved_name)
  values (p_id, o_name, o_lat, o_lng, p_lat, p_lng,
    round(6371000 * 2 * asin(sqrt(power(sin(radians(p_lat - o_lat) / 2), 2) + cos(radians(o_lat)) * cos(radians(p_lat)) * power(sin(radians(p_lng - o_lng) / 2), 2))))::integer,
    coalesce(emri, (select email from auth.users where id = auth.uid())));
end;
$$;

revoke all on function public.zhvendos_piken(text, double precision, double precision) from public, anon;
grant execute on function public.zhvendos_piken(text, double precision, double precision) to authenticated;

notify pgrst, 'reload schema';
