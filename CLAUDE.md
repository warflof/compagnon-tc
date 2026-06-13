# CLAUDE.md — Contexte du projet Compagnon Trench Crusade

## Le projet
Appli web de gestion de warbands et de suivi de campagne pour le jeu de figurines
**Trench Crusade**, destinée à un groupe privé de 6 joueurs (usage non commercial).
Le propriétaire du projet est Lucas (pseudo en jeu : Warf). Il pilote et relit ;
le code est largement généré par IA. **Commenter le code en français aux endroits
clés et expliquer les choix techniques quand il le demande, sans jargon inutile.**

## Stack (décidée, ne pas changer sans discussion)
- Vite + Vue 3 (Composition API, `<script setup>`) + Tailwind CSS v4
- Supabase : base Postgres + Auth (tier gratuit)
- Vue Router en mode **hash** (`createWebHashHistory`) — requis pour GitHub Pages
- Hébergement : GitHub Pages (site statique)

## Fonctionnalités v1 (périmètre validé)
1. Création complète de warbands dans l'appli (pas de dépendance au Trench Companion officiel)
2. Consultation des warbands des autres joueurs en **lecture seule**
3. Suivi de campagne partagé : parties, classement aux Points de Victoire de Campagne
4. Assistant/saisie post-bataille simplifiée

## Décisions actées (registre)
- Campagne **officielle 12 parties** ; paramètres (seuils 700→2200 ducats, PV par résultat,
  tailles max) dans un **fichier de config JSON** pour permettre du custom plus tard
- **Catalogues de factions en JSON** dans `src/data/` (un fichier par faction, saisis par
  les joueurs eux-mêmes) — les formulaires de l'appli s'en nourrissent (coûts auto).
  Jamais de données de jeu codées en dur.
- Parties **multi-joueurs permissives** : nombre libre de participants et de camps
  (1v1, 2v2, 3v3, 4v2, chacun-pour-soi…)
- Auth : **Supabase Auth sous le capot** — façade pseudo + PIN 4 chiffres, email technique
  interne du type `pseudo@campagne.local`, le PIN sert de mot de passe
- PIN oublié : réinitialisation **manuelle par l'admin** (Lucas) via le dashboard Supabase ;
  l'appli affiche juste un message d'aide
- Candidats v2 (ne pas implémenter sans demande) : modèles d'unités réutilisables,
  mécaniques custom type carte de territoire

## Modèle de données (5 tables Supabase, validé)
- **joueurs** : id, pseudo (unique), pin via Supabase Auth, cree_le
- **warbands** : id, joueur_id (FK), nom, faction (clé catalogue), patron,
  mode (`campagne`|`libre`), ducats_reserve, gloire_reserve, notes
  → la faction est portée par le warband, PAS par le joueur (multi-warbands toutes factions)
- **unites** : id, warband_id (FK), nom_perso, type_catalogue (clé catalogue),
  grade (`ELITE`|`TROUPE`), equipement (liste de clés armurerie), xp,
  cicatrices (0–2, morte à 3), competences (liste), statut (`active`|`morte`)
  → les unités mortes restent en base (mémorial, affichées grisées)
- **parties** : id, mode (`campagne`|`escarmouche`), numero_bataille (null si escarmouche),
  scenario, jouee_le, statut (`planifiee`|`jouee`), notes
- **participations** : id, partie_id (FK), warband_id (FK), camp (texte libre : A/B/C…),
  resultat (`victoire`|`defaite`|`nul`), points_victoire, gloire_gagnee,
  ducats_exploration, pertes (liste/texte), promotions (liste/texte),
  mvp (optionnel), notes
  → le classement de campagne s'obtient en agrégeant ces lignes

## Règles de sécurité (RLS, validées)
- joueurs : lecture des pseudos par tous les connectés ; modification de sa propre fiche
- warbands + unites : lecture par tous les connectés ; écriture par le **propriétaire seul**
- parties + participations : lecture ET écriture par **tout joueur connecté**
  (en soirée, une seule personne saisit pour tout le monde — choix assumé entre amis)

## Conventions du code
- Un fichier `.vue` par écran dans `src/views/`, composants partagés dans `src/components/`
- Client Supabase unique : `src/lib/supabase.js` (clés dans `.env`, jamais commitées)
- Les 8 écrans maquettés : Connexion, Accueil/Campagne, Mes warbands, Fiche warband
  (édition), Consultation warband adverse, Historique, Fiche de partie, Saisie de partie
  (3 étapes : cadre → participants/camps → résultats)
- Navigation : barre d'onglets bas de page (Campagne / Mes warbands / Historique / Joueurs)
- Direction artistique : à faire EN DERNIER (wireframes lo-fi validés). Ambiance visée :
  sobre, sombre, esprit "journal de tranchées" (stone/amber), mobile-first

## État d'avancement
- [x] Cadrage complet, modèle de données, règles de sécurité, wireframes
- [x] Squelette du projet (ce repo) : build OK, écran connexion non branché
- [x] Script SQL des tables + RLS dans Supabase (`supabase/schema.sql`)
- [x] Auth pseudo+PIN branchée (`src/lib/auth.js` + `ConnexionView.vue` + garde router)
- [ ] CRUD warbands/unités alimenté par les catalogues JSON
- [ ] Saisie de partie + classement de campagne
- [ ] Déploiement GitHub Pages + bataille test avec les 6 joueurs

## Notes techniques
- PIN : **6 chiffres** (et non 4 comme prévu initialement) — Supabase Auth exige un minimum
  de 6 caractères, on s'y conforme plutôt que de modifier la config
- npm : `strict-ssl false` configuré localement (proxy/antivirus qui intercepte le TLS)

## Question ouverte (à trancher avec le groupe)
La consultation des warbands adverses montre-t-elle tout, ou masque-t-on
l'équipement pour préserver la surprise tactique ?
