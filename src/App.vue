<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from './lib/supabase'
import { deconnecter } from './lib/auth'

const route = useRoute()
const router = useRouter()
const pseudo = ref('')

// La nav et le header s'affichent sur tous les écrans sauf la page de connexion
const afficherNav = () => route.path !== '/'

onMounted(() => {
  // Charge le pseudo au montage si une session est déjà active
  supabase.auth.getSession().then(({ data: { session } }) => {
    if (session) chargerPseudo(session.user.id)
  })

  // Met à jour le pseudo à chaque changement de session (connexion / déconnexion)
  supabase.auth.onAuthStateChange((_event, session) => {
    if (session) chargerPseudo(session.user.id)
    else pseudo.value = ''
  })
})

async function chargerPseudo(userId) {
  const { data } = await supabase.from('joueurs').select('pseudo').eq('id', userId).single()
  if (data) pseudo.value = data.pseudo
}

async function seDeconnecter() {
  await deconnecter()
  router.push('/')
}

// Onglets de navigation. actif:false = écran pas encore implémenté (grisé, non cliquable)
const onglets = [
  { label: 'Campagne',   path: '/campagne',   actif: true },
  { label: 'Warbands',   path: '/warbands',   actif: false },
  { label: 'Historique', path: '/historique', actif: false },
  { label: 'Joueurs',    path: '/joueurs',    actif: false },
  { label: 'Glossaire',  path: '/glossaire',  actif: true },
]
</script>

<template>
  <div class="min-h-screen bg-stone-900 text-stone-100">

    <!-- Header : pseudo + bouton déconnexion (masqué sur l'écran de connexion) -->
    <header
      v-if="afficherNav()"
      class="sticky top-0 z-10 bg-stone-900 border-b border-stone-700"
    >
      <div class="max-w-md mx-auto px-4 py-3 flex items-center justify-between">
        <span class="text-sm text-stone-300">{{ pseudo }}</span>
        <button
          @click="seDeconnecter"
          class="text-xs text-stone-500 hover:text-stone-200 transition-colors"
        >
          Déconnexion
        </button>
      </div>
    </header>

    <RouterView />

    <!-- Barre de navigation fixe en bas (masquée sur l'écran de connexion) -->
    <nav
      v-if="afficherNav()"
      class="fixed bottom-0 left-0 right-0 bg-stone-900 border-t border-stone-700"
    >
      <div class="max-w-md mx-auto flex">
        <template v-for="onglet in onglets" :key="onglet.path">
          <RouterLink
            v-if="onglet.actif"
            :to="onglet.path"
            :class="[
              'flex-1 flex flex-col items-center py-3 text-xs transition-colors',
              route.path === onglet.path ? 'text-amber-500' : 'text-stone-400 hover:text-stone-200',
            ]"
          >
            {{ onglet.label }}
          </RouterLink>
          <span
            v-else
            class="flex-1 flex flex-col items-center py-3 text-xs text-stone-700 cursor-not-allowed select-none"
          >
            {{ onglet.label }}
          </span>
        </template>
      </div>
    </nav>

  </div>
</template>
