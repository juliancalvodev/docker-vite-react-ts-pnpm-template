# --- Etapa Base: Instalación de pnpm y configuración del entorno ---
FROM node:24.12.0-alpine3.22 AS base
# Configuración de pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV PNPM_CONFIG_STORE_DIR="/pnpm/store"
RUN corepack enable
WORKDIR /app

# --- Etapa de Desarrollo: Entorno interactivo para programar ---
FROM base AS dev
# Copiamos archivos de dependencias para aprovechar la caché de capas de Docker
COPY app/package.json app/pnpm-lock.yaml* ./
# Instalación de dependencias (se sincronizará con el volumen del store si se usa Compose)
RUN pnpm install --frozen-lockfile
# Copiamos el resto del código
COPY app/ .
# Exponemos el puerto de Vite
EXPOSE 5173
# Comando para iniciar en modo desarrollo con host expuesto para Docker
CMD ["pnpm", "run", "dev", "--host"]

# --- Etapa de Build: Transpilación y minificación del código ---
FROM base AS build-stage
COPY app/package.json app/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY app/ .
RUN pnpm run build

# --- Etapa de Producción: Servidor ligero para despliegue ---
FROM nginx:1.28.1-alpine3.23 AS production
# Copiamos los archivos estáticos generados por Vite a la carpeta de Nginx
COPY --from=build-stage /app/dist /usr/share/nginx/html
# Exponemos el puerto estándar de HTTP
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
