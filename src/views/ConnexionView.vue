<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { connecter, inscrire } from '../lib/auth'

const router = useRouter()

const mode = ref('connexion') // 'connexion' | 'inscription'
const pseudo = ref('')
const pin = ref('')
const pinConfirm = ref('')
const erreur = ref('')
const chargement = ref(false)

// Messages d'erreur Supabase traduits en français
const messagesErreur = {
  'Invalid login credentials': 'Pseudo ou PIN incorrect.',
  'User already registered': 'Ce pseudo est déjà pris.',
  'Password should be at least 6 characters': 'Le PIN doit être exactement 6 chiffres.',
  'Email rate limit exceeded': 'Trop de tentatives. Réessaie dans quelques minutes.',
}

function traduireErreur(message) {
  for (const [clé, traduction] of Object.entries(messagesErreur)) {
    if (message.includes(clé)) return traduction
  }
  return 'Une erreur est survenue. Réessaie.'
}

function valider() {
  if (!pseudo.value.trim()) return 'Entre ton pseudo.'
  if (!/^\d{6}$/.test(pin.value)) return 'Le PIN doit être exactement 6 chiffres.'
  if (mode.value === 'inscription' && pin.value !== pinConfirm.value)
    return 'Les deux PIN ne correspondent pas.'
  return null
}

async function soumettre() {
  erreur.value = valider() ?? ''
  if (erreur.value) return

  chargement.value = true
  erreur.value = ''
  try {
    if (mode.value === 'connexion') {
      await connecter(pseudo.value, pin.value)
    } else {
      await inscrire(pseudo.value, pin.value)
    }
    router.push('/campagne')
  } catch (e) {
    erreur.value = traduireErreur(e.message)
  } finally {
    chargement.value = false
  }
}

function basculerMode() {
  mode.value = mode.value === 'connexion' ? 'inscription' : 'connexion'
  erreur.value = ''
  pin.value = ''
  pinConfirm.value = ''
}
</script>

<template>
  <main class="max-w-sm mx-auto px-6 py-16 flex flex-col gap-4">
    <h1 class="text-2xl font-bold text-center tracking-wide uppercase">
      Compagnon Trench Crusade
    </h1>
    <p class="text-center text-stone-400 text-sm">Campagne — 6 joueurs</p>

    <label class="text-xs uppercase tracking-wider text-stone-400 mt-6">Pseudo</label>
    <input
      v-model="pseudo"
      type="text"
      placeholder="Warf"
      autocomplete="username"
      class="bg-stone-800 border border-stone-600 rounded px-3 py-2.5 outline-none focus:border-amber-600"
    />

    <label class="text-xs uppercase tracking-wider text-stone-400">Code PIN</label>
    <input
      v-model="pin"
      type="password"
      inputmode="numeric"
      maxlength="6"
      placeholder="••••"
      autocomplete="off"
      class="bg-stone-800 border border-stone-600 rounded px-3 py-2.5 outline-none focus:border-amber-600"
    />

    <template v-if="mode === 'inscription'">
      <label class="text-xs uppercase tracking-wider text-stone-400">Confirme le PIN</label>
      <input
        v-model="pinConfirm"
        type="password"
        inputmode="numeric"
        maxlength="6"
        placeholder="••••"
        autocomplete="off"
        class="bg-stone-800 border border-stone-600 rounded px-3 py-2.5 outline-none focus:border-amber-600"
      />
    </template>

    <p v-if="erreur" class="text-red-400 text-sm text-center">{{ erreur }}</p>

    <button
      @click="soumettre"
      :disabled="chargement"
      class="mt-4 bg-amber-700 hover:bg-amber-600 disabled:opacity-50 disabled:cursor-not-allowed rounded py-3 font-semibold uppercase tracking-wider text-sm"
    >
      <span v-if="chargement">...</span>
      <span v-else-if="mode === 'connexion'">Entrer dans les tranchées</span>
      <span v-else>Créer mon compte</span>
    </button>

    <p class="text-center text-xs text-stone-500 mt-2">
      <span v-if="mode === 'connexion'">
        Pas encore de compte ?
        <button @click="basculerMode" class="underline hover:text-stone-300">S'inscrire</button>
      </span>
      <span v-else>
        Déjà un compte ?
        <button @click="basculerMode" class="underline hover:text-stone-300">Se connecter</button>
      </span>
    </p>

    <p v-if="mode === 'connexion'" class="text-center text-xs text-stone-600">
      PIN oublié ? Contacte Warf.
    </p>
  </main>
</template>
