import { createApp } from 'vue'
import { createRouter, createWebHashHistory } from 'vue-router'
import './style.css'
import App from './App.vue'
import ConnexionView from './views/ConnexionView.vue'
import AccueilView from './views/AccueilView.vue'
import GlossaireView from './views/GlossaireView.vue'
import { supabase } from './lib/supabase'

// Routes de l'appli — on utilise le mode "hash" (#/) :
// indispensable sur GitHub Pages pour éviter les erreurs 404 au rechargement
const routes = [
  { path: '/', component: ConnexionView },
  { path: '/campagne', component: AccueilView },
  { path: '/glossaire', component: GlossaireView },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

// Garde de navigation : protège toutes les routes sauf la page de connexion
router.beforeEach(async (to) => {
  try {
    const { data } = await supabase.auth.getSession()
    const connecte = !!data.session
    if (to.path !== '/' && !connecte) return '/'
    if (to.path === '/' && connecte) return '/campagne'
  } catch {
    // Supabase inaccessible (ex: .env absent) — on laisse passer vers la connexion
    if (to.path !== '/') return '/'
  }
})

createApp(App).use(router).mount('#app')
