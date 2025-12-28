# Stage 1: Base - Configuración compartida y preparación del gestor de paquetes
FROM node:24.12.0-alpine3.22 AS base

# Define la ruta para binarios y herramientas globales de pnpm
ENV PNPM_HOME="/pnpm"

# Agrega la ruta de binarios al PATH del sistema para que los comandos (ej. pnpm, serve) sean reconocidos
ENV PATH="$PNPM_HOME:$PATH"

# Define el directorio de trabajo principal dentro del contenedor
WORKDIR /app

# Habilita Corepack (gestor nativo de Node para pnpm/yarn) y activa la versión más reciente de pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Establece la ubicación del "content-addressable store". Esto es vital para que pnpm
# sepa dónde buscar las librerías vinculadas (symlinks) tanto en build como en runtime.
RUN pnpm config set store-dir /pnpm/store --global


# Stage 2: Dependencies - Instalación de paquetes con optimización de caché
FROM base AS deps

# Copia solo los archivos de definición de dependencias para aprovechar la caché de capas de Docker
COPY app/package.json app/pnpm-lock.yaml ./

# --mount=type=cache: Crea una caché persistente en el host de Docker identificada como 'pnpm'.
# target=/pnpm/store: Monta esa caché exactamente donde pnpm espera encontrar sus librerías.
# --frozen-lockfile: Asegura que la instalación sea exacta al lockfile sin modificarlo.
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile


# Stage 3: Development - Entorno para desarrollo activo (usado por Docker Compose)
FROM deps AS dev

# Informa que el contenedor escuchará en el puerto 5173 (puerto por defecto de Vite)
EXPOSE 5173

# Arranca el servidor de desarrollo.
# --host 0.0.0.0 es obligatorio para que el tráfico pase del host al contenedor.
CMD ["pnpm", "dev", "--host", "0.0.0.0"]


# Stage 4: Builder - Compilación de la aplicación para producción
FROM deps AS builder

# Copia el resto del código fuente del proyecto
COPY app/ .

# Ejecuta el script de construcción (genera la carpeta /dist con archivos estáticos)
RUN pnpm build


# Stage 5: Production - Imagen final minimalista basada en Servidor Web (Nginx)
FROM nginx:1.28.1-alpine3.23 AS production

# Copia los archivos estáticos generados en el stage anterior al directorio público de Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Expone el puerto estándar de HTTP
EXPOSE 80

# Inicia Nginx en primer plano para mantener el contenedor activo
CMD ["nginx", "-g", "daemon off;"]
