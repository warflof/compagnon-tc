# Compagnon Trench Crusade ⚜

Appli de gestion de warbands et de suivi de campagne pour notre groupe de 6 joueurs.

## Stack
- [Vite](https://vite.dev) + [Vue 3](https://vuejs.org) + [Tailwind CSS v4](https://tailwindcss.com)
- [Supabase](https://supabase.com) (base de données + authentification)
- Hébergement : GitHub Pages

## Démarrer en local
```bash
npm install
cp .env.example .env   # puis remplir avec les clés du projet Supabase
npm run dev            # http://localhost:5173
```

## Structure
```
src/
  lib/supabase.js   ← client Supabase (lit les clés depuis .env)
  views/            ← un fichier .vue par écran
  data/             ← catalogues JSON des factions (à venir)
```

## Décisions clés
Voir le journal de pilotage du projet. En résumé : campagne officielle 12 parties,
catalogues de factions en JSON, auth pseudo+PIN via Supabase Auth,
warbands modifiables par leur propriétaire seul.
