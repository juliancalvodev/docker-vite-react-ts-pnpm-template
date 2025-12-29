#!/bin/sh

# Color para logs
GREEN='\033[0;32m'
NC='\033[0m'
VOLUME_NAME="pnpm_shared_store"

# 1. Capturar la ruta enviada por VS Code
# Si no se envía nada, usamos el directorio actual como fallback
PROJECT_PATH=${1:-$(pwd)}

echo "${GREEN}🔍 Verificando estado del proyecto...${NC}"

# Nos movemos a la ruta del proyecto
cd "$PROJECT_PATH"

# 2. Asegurar la existencia del volumen de forma explícita
# Esto garantiza que el volumen se cree con el nombre exacto antes de ser usado
if ! docker volume inspect $VOLUME_NAME >/dev/null 2>&1; then
    echo "📦 Creando volumen persistente: $VOLUME_NAME..."
    docker volume create --name $VOLUME_NAME
fi

# 2. Comprobar si existe la carpeta 'app'
if [ ! -d "app" ]; then
    echo "🚀 Inicializando Vite + React + TS...(en la carpeta 'app')..."

    # Ejecutamos el contenedor para inicializar el proyecto
    # IMPORTANTE: Usamos PROJECT_PATH para el montaje del volumen host
    # Nota: Usamos el ID del usuario actual para evitar problemas de permisos en el host
    docker run --rm \
      -v "$PROJECT_PATH":/work \
      -v $VOLUME_NAME:/pnpm/store \
      -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
      -w /work node:24.12.0-alpine3.22 \
      sh -c "corepack enable && pnpm create vite app --template react-ts --yes && pnpm install --dir app --store-dir /pnpm/store"

    echo "📦 Entorno del contenedor preparado..."
else
    echo "✅ El proyecto ya existe. Saltando inicialización."
fi

echo "${GREEN}✨ Entorno listo para desarrollar.${NC}"
