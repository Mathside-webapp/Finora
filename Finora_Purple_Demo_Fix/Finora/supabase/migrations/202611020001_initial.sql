-- Finora v1: per-user finance document records. Money amounts are integer minor units
-- in payload JSON (cents), and must be validated by clients and the database.
create extension if not exists pgcrypto;
create table if not exists public.finance_records (
 id uuid primary key,
 user_id uuid not null references auth.users(id) on delete cascade,
 kind text not null check (kind in ('account','transaction','budget','borrower','receivable','receivable_payment','debt','debt_payment','bill','bill_payment','card','card_charge','card_payment','transfer')),
 payload jsonb not null,
 updated_at timestamptz not null default now(),
 constraint payload_object check (jsonb_typeof(payload)='object'),
 constraint owner_consistency check (payload->>'user_id'=user_id::text),
 constraint id_consistency check (payload->>'id'=id::text),
 constraint kind_consistency check (payload->>'kind'=kind)
);

create or replace function public.finora_valid_money(doc jsonb) returns boolean
language sql immutable set search_path = '' as $$
 select not exists (
  select 1 from jsonb_each_text(doc) as e(k,v)
  where e.k like '%_cents' and (e.v !~ '^[0-9]{1,15}$')
 );
$$;
alter table public.finance_records add constraint money_minor_units_valid check (public.finora_valid_money(payload));
create index if not exists finance_records_owner_kind on public.finance_records(user_id,kind);
create index if not exists finance_records_owner_updated on public.finance_records(user_id,updated_at desc);
alter table public.finance_records enable row level security;
create policy "owner select" on public.finance_records for select to authenticated using ((select auth.uid())=user_id);
create policy "owner insert" on public.finance_records for insert to authenticated with check ((select auth.uid())=user_id);
create policy "owner update" on public.finance_records for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "owner delete" on public.finance_records for delete to authenticated using ((select auth.uid())=user_id);
-- Protect ownership and identity on updates. Server sets authoritative timestamp.
create or replace function public.finora_record_guard() returns trigger language plpgsql security invoker set search_path='' as $$
begin
 if tg_op='UPDATE' and (new.id<>old.id or new.user_id<>old.user_id) then
  raise exception 'Record identity cannot change';
 end if;
 new.updated_at=now();
 return new;
end;$$;
create trigger finora_record_guard before insert or update on public.finance_records for each row execute function public.finora_record_guard();
revoke all on function public.finora_valid_money(jsonb) from public;
grant execute on function public.finora_valid_money(jsonb) to authenticated;
