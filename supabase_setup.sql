-- 유 패밀리 오사카 지출내역 테이블 (Supabase → SQL Editor 에 붙여넣고 Run)
create table if not exists public.osaka_expenses (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  day         date not null,
  title       text not null,
  category    text not null default '기타',
  amount_yen  integer not null check (amount_yen >= 0),
  payer       text default '공용',
  memo        text default ''
);

alter table public.osaka_expenses enable row level security;

-- 링크를 아는 사람(가족)이 읽기·추가·삭제할 수 있게 허용
create policy "family read"   on public.osaka_expenses for select using (true);
create policy "family insert" on public.osaka_expenses for insert with check (true);
create policy "family delete" on public.osaka_expenses for delete using (true);
