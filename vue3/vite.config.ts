import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'
import { createSvgIconsPlugin } from 'vite-plugin-svg-icons'
import viteCompression from 'vite-plugin-compression'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd())

  return {
    plugins: [
      vue(),
      createSvgIconsPlugin({
        iconDirs: [path.resolve(process.cwd(), 'src/assets/icons')],
        symbolId: 'icon-[dir]-[name]',
      }),
      viteCompression({
        verbose: false,
        disable: mode === 'development',
        threshold: 10240,
        algorithm: 'gzip',
        ext: '.gz',
      }),
    ],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, 'src'),
        '~': path.resolve(__dirname, 'src'),
      },
    },
    define: {
      'process.env.VUE_APP_BASE_API': JSON.stringify(env.VITE_APP_BASE_API),
    },
    server: {
      host: '0.0.0.0',
      port: 88,
      proxy: {
        '/api': {
          target: env.VITE_APP_BASE_API || 'http://localhost:8088',
          changeOrigin: true,
        },
      },
    },
    css: {
      preprocessorOptions: {
        scss: {},
      },
    },

  }
})
