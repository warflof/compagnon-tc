import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'

// Config Vite : plugin Vue + plugin Tailwind v4
// base : sous-chemin GitHub Pages (nom du repo)
export default defineConfig({
  base: '/compagnon-tc/',
  plugins: [vue(), tailwindcss()],
})
