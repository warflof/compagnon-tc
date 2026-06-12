import { createApp } from 'vue'
import { createRouter, createWebHashHistory } from 'vue-router'
import './style.css'
import App from './App.vue'
import ConnexionView from './views/ConnexionView.vue'
import AccueilView from './views/AccueilView.vue'

// Routes de l'appli — on utilise le mode "hash" (#/) :
// indispensable sur GitHub Pages pour éviter les erreurs 404 au rechargement
const routes = [
  { path: '/', component: ConnexionView },
  { path: '/campagne', component: AccueilView },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

createApp(App).use(router).mount('#app')
