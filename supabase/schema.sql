-- ============================================================
-- COMPAGNON TRENCH CRUSADE — Schéma de base de données
-- À coller dans : Dashboard Supabase > SQL Editor > New query > Run
-- Idempotent non garanti : prévu pour une base vierge.
-- ============================================================

-- ------------------------------------------------------------
-- 1. JOUEURS
-- Chaque joueur correspond à un compte Supabase Auth.
-- L'id N'EST PAS généré ici : c'est celui de auth.users,
-- ce qui permet d'écrire les règles "le proprio seul" avec auth.uid().
-- Le PIN n'apparaît nulle part : c'est le mot de passe géré par Supabase Auth.
-- ------------------------------------------------------------
create table public.joueurs (
  id uuid primary key references auth.users(id) on delete cascade,
  pseudo text not null unique,
  cree_le timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 2. WARBANDS
-- La faction est portée ici (pas par le joueur) : un joueur peut
-- avoir plusieurs warbands, de factions différentes.
-- ------------------------------------------------------------
create table public.warbands (
  id uuid primary key default gen_random_uuid(),
  joueur_id uuid not null references public.joueurs(id) on delete cascade,
  nom text not null,
  faction text not null,                -- clé du catalogue JSON (ex: 'trench_pilgrims')
  patron text,
  mode text not null default 'campagne' check (mode in ('campagne', 'libre')),
  ducats_reserve integer not null default 0,
  gloire_reserve integer not null default 0,
  notes text,
  cree_le timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 3. UNITES
-- Une ligne par figurine. Les unités mortes restent en base
-- (statut 'morte') pour le mémorial du warband.
-- equipement et competences en jsonb : listes simples,
-- les coûts sont recalculés côté appli via les catalogues JSON.
-- ------------------------------------------------------------
create table public.unites (
  id uuid primary key default gen_random_uuid(),
  warband_id uuid not null references public.warbands(id) on delete cascade,
  nom_perso text not null,
  type_catalogue text not null,         -- clé du catalogue JSON (ex: 'war_prophet')
  grade text not null default 'TROUPE' check (grade in ('ELITE', 'TROUPE')),
  equipement jsonb not null default '[]'::jsonb,
  xp integer not null default 0,
  cicatrices integer not null default 0 check (cicatrices between 0 and 3),
  competences jsonb not null default '[]'::jsonb,
  statut text not null default 'active' check (statut in ('active', 'morte')),
  cree_le timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 4. PARTIES
-- Une ligne par bataille (jouée ou planifiée).
-- numero_bataille est null pour les escarmouches libres.
-- ------------------------------------------------------------
create table public.parties (
  id uuid primary key default gen_random_uuid(),
  mode text not null default 'campagne' check (mode in ('campagne', 'escarmouche')),
  numero_bataille integer,
  scenario text,
  jouee_le timestamptz,
  statut text not null default 'planifiee' check (statut in ('planifiee', 'jouee')),
  notes text,
  cree_le timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 5. PARTICIPATIONS
-- Le cœur du système : une ligne par warband engagé dans une partie.
-- camp en texte libre (A/B/C...) => 1v1, 2v2, 3v3, 4v2, FFA, tout passe.
-- Le classement de campagne s'obtient en agrégeant ces lignes.
-- ------------------------------------------------------------
create table public.participations (
  id uuid primary key default gen_random_uuid(),
  partie_id uuid not null references public.parties(id) on delete cascade,
  warband_id uuid not null references public.warbands(id) on delete cascade,
  camp text not null default 'A',
  resultat text check (resultat in ('victoire', 'defaite', 'nul')),
  points_victoire integer not null default 0,
  gloire_gagnee integer not null default 0,
  ducats_exploration integer not null default 0,
  pertes jsonb not null default '[]'::jsonb,
  promotions jsonb not null default '[]'::jsonb,
  mvp text,
  notes text,
  unique (partie_id, warband_id)        -- un warband ne participe qu'une fois par partie
);

-- ============================================================
-- RÈGLES DE SÉCURITÉ (Row Level Security)
-- Philosophie validée :
--   - warbands + unites : lecture par tous les connectés,
--     écriture par le PROPRIÉTAIRE seul
--   - parties + participations : lecture ET écriture par
--     tout joueur connecté (saisie par une seule personne en soirée)
--   - aucune table accessible sans être connecté
-- ============================================================

alter table public.joueurs enable row level security;
alter table public.warbands enable row level security;
alter table public.unites enable row level security;
alter table public.parties enable row level security;
alter table public.participations enable row level security;

-- --- JOUEURS ---
-- Tous les connectés voient les pseudos (nécessaire pour classement & listes)
create policy "joueurs_lecture" on public.joueurs
  for select to authenticated using (true);

-- Chacun crée sa propre fiche à l'inscription (id = son compte Auth)
create policy "joueurs_creation" on public.joueurs
  for insert to authenticated with check (id = auth.uid());

-- Chacun modifie sa propre fiche uniquement
create policy "joueurs_modif" on public.joueurs
  for update to authenticated using (id = auth.uid());

-- --- WARBANDS ---
create policy "warbands_lecture" on public.warbands
  for select to authenticated using (true);

create policy "warbands_creation" on public.warbands
  for insert to authenticated with check (joueur_id = auth.uid());

create policy "warbands_modif" on public.warbands
  for update to authenticated using (joueur_id = auth.uid());

create policy "warbands_suppression" on public.warbands
  for delete to authenticated using (joueur_id = auth.uid());

-- --- UNITES ---
-- Le droit d'écriture remonte au propriétaire du warband parent
create policy "unites_lecture" on public.unites
  for select to authenticated using (true);

create policy "unites_creation" on public.unites
  for insert to authenticated with check (
    exists (
      select 1 from public.warbands w
      where w.id = warband_id and w.joueur_id = auth.uid()
    )
  );

create policy "unites_modif" on public.unites
  for update to authenticated using (
    exists (
      select 1 from public.warbands w
      where w.id = warband_id and w.joueur_id = auth.uid()
    )
  );

create policy "unites_suppression" on public.unites
  for delete to authenticated using (
    exists (
      select 1 from public.warbands w
      where w.id = warband_id and w.joueur_id = auth.uid()
    )
  );

-- --- PARTIES --- (ouvertes à tous les connectés, décision d9)
create policy "parties_lecture" on public.parties
  for select to authenticated using (true);

create policy "parties_creation" on public.parties
  for insert to authenticated with check (true);

create policy "parties_modif" on public.parties
  for update to authenticated using (true);

create policy "parties_suppression" on public.parties
  for delete to authenticated using (true);

-- --- PARTICIPATIONS --- (mêmes règles que parties)
create policy "participations_lecture" on public.participations
  for select to authenticated using (true);

create policy "participations_creation" on public.participations
  for insert to authenticated with check (true);

create policy "participations_modif" on public.participations
  for update to authenticated using (true);

create policy "participations_suppression" on public.participations
  for delete to authenticated using (true);

-- ============================================================
-- INDEX (confort de requêtes pour le classement et les fiches)
-- ============================================================
create index idx_warbands_joueur on public.warbands(joueur_id);
create index idx_unites_warband on public.unites(warband_id);
create index idx_participations_partie on public.participations(partie_id);
create index idx_participations_warband on public.participations(warband_id);

-- Fin du script. Vérification rapide après exécution :
-- Dashboard > Table Editor : les 5 tables doivent apparaître,
-- chacune avec le badge "RLS enabled".
