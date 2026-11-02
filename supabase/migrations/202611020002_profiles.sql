-- Finora account profiles. Supabase Auth handles credentials.
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 email text,
 full_name text,
 preferred_currency text not null default 'PHP',
 created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles for select to authenticated using ((select auth.uid()) = id);
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create or replace function public.handle_new_finora_user() returns trigger language plpgsql security definer set search_path = '' as $$
begin
 insert into public.profiles (id,email,full_name) values (new.id,new.email,new.raw_user_meta_data ->> 'full_name') on conflict (id) do nothing;
 return new;
end; $$;
drop trigger if exists on_finora_user_created on auth.users;
create trigger on_finora_user_created after insert on auth.users for each row execute function public.handle_new_finora_user();
-- Backfill profiles for users registered before this migration.
insert into public.profiles (id,email,full_name)
select id,email,raw_user_meta_data ->> 'full_name' from auth.users
on conflict (id) do nothing;
