import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: true,
    proxy: {
      '/api': {
        target: 'http://80.241.218.23:8085',
        changeOrigin: true,
      },
      '/uploads': {
        target: 'http://80.241.218.23:8085',
        changeOrigin: true,
      }
    }
  }
});
