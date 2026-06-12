import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'

// Config Vite : plugin Vue + plugin Tailwind v4
// "base" sera à ajuster quand on déploiera sur GitHub Pages
// (ex: base: '/compagnon-tc/' si le repo s'appelle compagnon-tc)
export default defineConfig({
  plugins: [vue(), tailwindcss()],
})
