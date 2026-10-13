-- ═══════════════════════════════════════════════════════
-- 유 패밀리 오사카 — Supabase 설정 (SQL Editor에 통째로 붙여넣고 Run 한 번)
-- 지출내역 표 + 앨범 표 + 앨범 사진 보관함(Storage)을 한 번에 만들어요
-- ═══════════════════════════════════════════════════════

-- 1) 지출내역
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
drop policy if exists "osaka exp read"   on public.osaka_expenses;
drop policy if exists "osaka exp insert" on public.osaka_expenses;
drop policy if exists "osaka exp delete" on public.osaka_expenses;
create policy "osaka exp read"   on public.osaka_expenses for select using (true);
create policy "osaka exp insert" on public.osaka_expenses for insert with check (true);
create policy "osaka exp delete" on public.osaka_expenses for delete using (true);

-- 2) 앨범 사진 목록
create table if not exists public.osaka_photos (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  day         date not null,
  path        text not null,
  uploader    text default ''
);
alter table public.osaka_photos enable row level security;
drop policy if exists "osaka photo read"   on public.osaka_photos;
drop policy if exists "osaka photo insert" on public.osaka_photos;
drop policy if exists "osaka photo delete" on public.osaka_photos;
create policy "osaka photo read"   on public.osaka_photos for select using (true);
create policy "osaka photo insert" on public.osaka_photos for insert with check (true);
create policy "osaka photo delete" on public.osaka_photos for delete using (true);

-- 3) 사진 보관함 (공개 버킷, 한 장당 최대 10MB, 이미지만)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('osaka-album', 'osaka-album', true, 10485760, array['image/jpeg','image/png','image/webp','image/heic','image/heif'])
on conflict (id) do update set public = true;

drop policy if exists "osaka album read"   on storage.objects;
drop policy if exists "osaka album upload" on storage.objects;
drop policy if exists "osaka album delete" on storage.objects;
create policy "osaka album read"   on storage.objects for select using (bucket_id = 'osaka-album');
create policy "osaka album upload" on storage.objects for insert with check (bucket_id = 'osaka-album');
create policy "osaka album delete" on storage.objects for delete using (bucket_id = 'osaka-album');
