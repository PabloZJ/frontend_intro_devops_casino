# ─── Stage 1: builder ───────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar dependencias primero para aprovechar cache de capas
COPY package*.json ./
RUN npm ci

# Copiar el resto del código y compilar en modo producción
COPY . .
RUN npm run build

# ─── Stage 2: runtime ───────────────────────────────────────────────────────
FROM nginxinc/nginx-unprivileged:alpine AS runtime

# Copiar configuración de Nginx (reverse proxy + SPA fallback)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Angular 17 genera en dist/casino-frontend/browser/ (subcarpeta extra vs v16)
COPY --from=builder /app/dist/casino-frontend/browser /usr/share/nginx/html

# nginx-unprivileged escucha en 8080 (no necesita root para el puerto 80)
EXPOSE 8080
