<script setup>
import { ref, computed } from 'vue'
import data from '../data/keywords.json'

// Le JSON a une enveloppe { _meta, keywords: [...] }
const liste = data.keywords

const recherche = ref('')
const categorieActive = ref('Toutes')

// Liste dédoublonnée et triée des catégories présentes dans le JSON
const categories = computed(() => {
  const uniques = [...new Set(liste.map(k => k.categorie))].sort()
  return ['Toutes', ...uniques]
})

// Filtre catégorie puis filtre texte sur nom ET nom_fr (insensible à la casse)
const keywordsFiltres = computed(() => {
  const terme = recherche.value.toLowerCase().trim()
  return liste
    .filter(k => categorieActive.value === 'Toutes' || k.categorie === categorieActive.value)
    .filter(k =>
      k.nom.toLowerCase().includes(terme) ||
      (k.nom_fr ?? '').toLowerCase().includes(terme)
    )
})
</script>

<template>
  <!-- pb-20 pour ne pas être masqué par la barre de nav fixe -->
  <main class="max-w-md mx-auto px-4 py-6 pb-20">
    <h1 class="text-xl font-bold uppercase tracking-wide mb-4">Glossaire</h1>

    <input
      v-model="recherche"
      type="search"
      placeholder="Rechercher un keyword..."
      class="w-full bg-stone-800 border border-stone-600 rounded px-3 py-2.5 outline-none focus:border-amber-600 mb-3"
    />

    <!-- Filtres par catégorie — défilement horizontal sur mobile -->
    <div class="flex gap-2 overflow-x-auto pb-2 mb-4">
      <button
        v-for="cat in categories"
        :key="cat"
        @click="categorieActive = cat"
        :class="[
          'px-3 py-1 rounded-full text-xs uppercase tracking-wider whitespace-nowrap flex-shrink-0 transition-colors',
          categorieActive === cat
            ? 'bg-amber-700 text-stone-100'
            : 'bg-stone-800 text-stone-400 hover:text-stone-200',
        ]"
      >
        {{ cat }}
      </button>
    </div>

    <p v-if="keywordsFiltres.length === 0" class="text-stone-500 text-sm text-center mt-8">
      Aucun keyword trouvé.
    </p>

    <ul class="flex flex-col gap-2">
      <li
        v-for="kw in keywordsFiltres"
        :key="kw.nom"
        class="bg-stone-800 border border-stone-700 rounded p-3"
      >
        <div class="flex items-start justify-between gap-2 mb-1">
          <span class="font-semibold text-sm">
            {{ kw.nom }}<span v-if="kw.nom_fr" class="text-stone-400 font-normal"> / {{ kw.nom_fr }}</span>
          </span>
          <div class="flex items-center gap-2 flex-shrink-0">
            <span class="text-xs text-stone-500 uppercase tracking-wider">{{ kw.categorie }}</span>
            <!-- Indicateur visuel : entrée incomplète dans le JSON -->
            <span
              v-if="kw.a_completer"
              class="text-xs bg-amber-900/60 text-amber-400 border border-amber-700 rounded px-1.5 py-0.5"
            >
              A compléter
            </span>
          </div>
        </div>
        <p class="text-sm text-stone-400 leading-relaxed">{{ kw.definition }}</p>
      </li>
    </ul>
  </main>
</template>
