<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

// La nav s'affiche sur tous les écrans sauf la page de connexion
const afficherNav = computed(() => route.path !== '/')

// Onglets de navigation. actif:false = écran pas encore implémenté (grisé, non cliquable)
const onglets = [
  { label: 'Campagne',  path: '/campagne',   actif: true },
  { label: 'Warbands',  path: '/warbands',   actif: false },
  { label: 'Historique', path: '/historique', actif: false },
  { label: 'Joueurs',   path: '/joueurs',    actif: false },
  { label: 'Glossaire', path: '/glossaire',  actif: true },
]
</script>

<template>
  <div class="min-h-screen bg-stone-900 text-stone-100">
    <RouterView />

    <nav
      v-if="afficherNav"
      class="fixed bottom-0 left-0 right-0 bg-stone-900 border-t border-stone-700"
    >
      <div class="max-w-md mx-auto flex">
        <template v-for="onglet in onglets" :key="onglet.path">
          <!-- Onglet implémenté : RouterLink navigable -->
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
          <!-- Onglet non encore implémenté : grisé, non cliquable -->
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
