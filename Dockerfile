# Stage 1: Base - Instalación de pnpm y configuración del entorno ---
FROM node:24.12.0-alpine3.22 AS base
# Configuración de pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN pnpm config set store-dir /pnpm/store --global

# Stage 2: Dependencies - Solo instala si cambian los lockfiles
FROM base AS deps
COPY app/package.json app/pnpm-lock.yaml ./
# En local, el compose montará el store, pero aquí lo preparamos
# AJUSTE CLAVE: Usamos un mount de caché apuntando a la MISMA ruta del store.
# Esto acelera el build y asegura que los enlaces simbólicos se creen correctamente.
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile

# Stage 3: Development (Target para Compose)
FROM deps AS dev
# No copiamos el código aquí porque el Compose lo monta como volumen
# Exponemos el puerto de Vite
EXPOSE 5173
# Comando para iniciar en modo desarrollo con host expuesto para Docker
CMD ["pnpm", "dev", "--host", "0.0.0.0"]

# Stage 4: Builder (Para producción)
FROM deps AS builder
COPY app/ .
RUN pnpm build

# Stage 5: Production (Imagen final ligera)
FROM nginx:1.28.1-alpine3.23 AS production
COPY --from=builder /app/dist /usr/share/nginx/html
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
