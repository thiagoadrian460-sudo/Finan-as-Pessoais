-- ============================================================
--  Balizador da Casa — tabelas novas
--  Rode UMA vez no SQL Editor do Supabase do app
--  (projeto dhnwdkulunvubrittkvq → SQL Editor → New query → Run)
-- ============================================================

-- 1) Agenda: contas a pagar + recorrências (entradas/saídas fixas)
create table if not exists public.compromissos (
  id uuid primary key default gen_random_uuid(),
  quem text not null default 'Casa',
  tipo text not null default 'pagar',      -- 'pagar' | 'entrada' | 'saida'
  titulo text not null,
  valor numeric not null default 0,
  dia int not null,                          -- dia do mês (1-31)
  recorrente boolean not null default true,
  ativo boolean not null default true,
  criado_at timestamptz not null default now()
);

-- 2) Bloco de notas (uma anotação por pessoa)
create table if not exists public.notas (
  quem text primary key,                     -- 'Adrian' | 'Larissa'
  conteudo text default '',
  updado_at timestamptz not null default now()
);

-- 3) Segurança (app privado do casal): usuários logados podem tudo
alter table public.compromissos enable row level security;
alter table public.notas        enable row level security;

drop policy if exists "compromissos auth all" on public.compromissos;
create policy "compromissos auth all" on public.compromissos
  for all to authenticated using (true) with check (true);

drop policy if exists "notas auth all" on public.notas;
create policy "notas auth all" on public.notas
  for all to authenticated using (true) with check (true);
