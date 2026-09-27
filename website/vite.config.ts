import path from 'node:path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig(({ command }) => ({
  // Dev serves at the root so the preview opens cleanly; the production build
  // uses the repo sub-path for GitHub Pages (https://mercyy00.github.io/Raaga/).
  base: command === 'build' ? '/Raaga/' : '/',
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
}))
