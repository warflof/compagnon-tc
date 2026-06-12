<script setup>
// Écran de connexion — pseudo + PIN (placeholder pour l'instant,
// le branchement Supabase Auth arrive à l'étape suivante)
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const pseudo = ref('')
const pin = ref('')
const router = useRouter()

function seConnecter() {
  // TODO : authentification Supabase (étape "connexion")
  router.push('/campagne')
}
</script>

<template>
  <main class="max-w-sm mx-auto px-6 py-16 flex flex-col gap-4">
    <h1 class="text-2xl font-bold text-center tracking-wide uppercase">
      Compagnon Trench Crusade
    </h1>
    <p class="text-center text-stone-400 text-sm">Campagne — 6 joueurs</p>

    <label class="text-xs uppercase tracking-wider text-stone-400 mt-6">Pseudo</label>
    <input v-model="pseudo" type="text" placeholder="Warf"
      class="bg-stone-800 border border-stone-600 rounded px-3 py-2.5 outline-none focus:border-amber-600" />

    <label class="text-xs uppercase tracking-wider text-stone-400">Code PIN</label>
    <input v-model="pin" type="password" inputmode="numeric" maxlength="4" placeholder="••••"
      class="bg-stone-800 border border-stone-600 rounded px-3 py-2.5 outline-none focus:border-amber-600" />

    <button @click="seConnecter"
      class="mt-4 bg-amber-700 hover:bg-amber-600 rounded py-3 font-semibold uppercase tracking-wider text-sm">
      Entrer dans les tranchées
    </button>

    <p class="text-center text-xs text-stone-500 mt-2">PIN oublié ? Contacte Warf 😄</p>
  </main>
</template>
