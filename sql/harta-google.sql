-- PikaBlu: tabela private e konfigurimit (çelësi i Google Maps)
-- Çelësi NUK ruhet në kod as në GitHub. Lexohet vetëm nga përdoruesit e identifikuar.
-- Ekzekutojeni një herë te Supabase > SQL Editor.

create table if not exists public.app_config (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

alter table public.app_config enable row level security;

-- Vetëm stafi me llogari e lexon çelësin e hartës. Pa leje shtimi/ndryshimi nga aplikacioni:
-- vlerat ndryshohen vetëm nga SQL Editor.
drop policy if exists "config lexim" on public.app_config;
create policy "config lexim" on public.app_config for select to authenticated
  using (key = 'google_maps_key');

notify pgrst, 'reload schema';

-- Vendosja ose ndryshimi i çelësit (zëvendësoni CELESI_JUAJ dhe ekzekutoni vetëm këtë rresht):
-- insert into public.app_config (key, value) values ('google_maps_key', 'CELESI_JUAJ')
--   on conflict (key) do update set value = excluded.value, updated_at = now();
