# 🚀 Docker + Vite + React (TS) + pnpm Template

Esta es una plantilla profesional para desarrollar aplicaciones modernas con **React** y **Vite**, utilizando **Docker** como entorno aislado. Diseñada específicamente para programadores que prefieren mantener su sistema operativo host limpio, sin necesidad de instalar Node.js, pnpm o dependencias globales directamente en el equipo.


## 🛠 Características

* **Aislamiento total**: Todo el ciclo de vida (creación, desarrollo y build) ocurre dentro de contenedores.

* **Zero-Config con VS Code**: Inicialización automática del proyecto y del volumen persistente al abrir el contenedor.

* **Gestión con pnpm**: Instalaciones ultra rápidas y uso eficiente del disco duro.

* **Store compartido**: Uso de un volumen externo de Docker para compartir librerías entre múltiples proyectos y ahorrar espacio.

* **Hot Reload optimizado**: Configuración lista para detectar cambios en el host desde el contenedor (HMR).

* **Imagen de Producción Profesional**: Construcción multi-etapa que genera una imagen final basada en **Nginx Alpine** (~30MB).


## 📋 Requisitos Previos

1.  **Docker** y **Docker Compose** instalados en el sistema.

2.  **VS Code** con la extensión [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) instalada (Recomendado para la automatización total).


---


## ⚡ Guía de Inicio Rápido (Recomendado: VS Code)

Si utilizas VS Code, no necesitas ejecutar comandos manuales en tu terminal local para inicializar el proyecto:

1.  Abre la carpeta raíz del proyecto en VS Code.

2.  Haz clic en el botón azul de la esquina inferior izquierda o abre la paleta de comandos (`Ctrl+Shift+P` / `Cmd+Shift+P`) y selecciona: **"Dev Containers: Reopen in Container"**.

3.  **Automatización**: El entorno detectará automáticamente si el volumen `pnpm_shared_store` existe (y lo creará si no) y ejecutará el scaffolding de Vite en la carpeta `app/` si aún no ha sido creada.

4.  La terminal integrada se abrirá automáticamente en la ruta `/work/app`, lista para trabajar.


---


## 🛠️ Guía Manual (Línea de comandos)

Si prefieres no usar la automatización de VS Code o utilizas otro editor, sigue estos pasos:

1.  **Crear el Volumen Global** (Se hace una sola vez):
    ```bash
    docker volume create pnpm_shared_store
    ```

2.  **Inicializar el proyecto**:
    Ejecuta este comando para crear la subcarpeta `app/` (esto descargará la imagen de Node y ejecutará el scaffolding de Vite):
    ```bash
    docker run --rm \
      -v $(pwd):/work \
      -v pnpm_shared_store:/pnpm/store \
      -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
      -w /work node:24.12.0-alpine3.22 \
      sh -c "corepack enable && pnpm create vite app --template react-ts --yes && pnpm install --dir app --store-dir /pnpm/store"
    ```

3.  **Levantar Entorno de Desarrollo**:
    ```bash
    docker compose up --build -d
    ```
    Accede a la aplicación en: [http://localhost:5173](http://localhost:5173)


---


## 📂 Estructura del Proyecto

* `.devcontainer/`: Configuración y scripts de automatización para VS Code.

* `app/`: Carpeta que contiene el código fuente de la aplicación React (generada automáticamente).

* `Dockerfile`: Definición de la imagen con múltiples etapas (deps, dev, builder, production).

* `docker-compose.yml`: Orquestador para el entorno de desarrollo, volúmenes y red.


## 🛠 Comandos Útiles dentro del Contenedor

* **Instalar nuevas dependencias**: `pnpm add <nombre-paquete>` (desde la terminal de VS Code).

* **Desde el host**: `docker compose exec app-react pnpm add <nombre-paquete>`.

* **Construir Imagen de Producción**:
    ```bash
    docker build --target production -t nombre-de-tu-app:latest .
    ```


## 🧹 Limpieza y Mantenimiento

* **Detener contenedores**: `docker compose down`

* **Limpiar módulos del contenedor**: `docker compose down -v` (Elimina volúmenes locales, pero mantiene el store global).

* **Limpiar Store Global**: Si deseas liberar espacio de todas las librerías descargadas de todos tus proyectos:
    ```bash
    docker volume rm pnpm_shared_store
    ```


## 📜 Licencia

Este proyecto está bajo la Licencia MIT. Siéntete libre de usarlo, modificarlo y distribuirlo.


## ¿Cómo usar esta plantilla?

1. Haz clic en el botón **"Use this template"** en GitHub.

2. Clona tu nuevo repositorio.

3. Sigue la **Guía de Inicio Rápido**.
