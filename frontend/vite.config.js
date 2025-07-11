import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    host: "0.0.0.0", // <--- PENTING
    allowedHosts: [".ngrok-free.app"],
    port: 5174, // pastikan konsisten (jika mau fix)
  },
});
