# 🚀 Docker + Vite + React (TS) + pnpm Template

Esta es una plantilla profesional para desarrollar aplicaciones modernas con **React** y **Vite**, utilizando **Docker** como entorno aislado. Diseñada específicamente para programadores que prefieren mantener su sistema operativo host limpio, sin necesidad de instalar Node.js, pnpm o dependencias globales directamente en el equipo.


## 🛠 Características

* **Aislamiento total**: Todo el ciclo de vida (creación, desarrollo y build) ocurre dentro de contenedores.

* **Gestión con pnpm**: Instalaciones ultra rápidas y eficiente uso de disco.

* **Store compartido**: Uso de un volumen externo de Docker para compartir librerías entre múltiples proyectos y ahorrar espacio.

* **Hot Reload optimizado**: Configuración lista para detectar cambios en el host desde el contenedor.

* **Imagen de Producción Profesional**: Construcción multi-etapa que genera una imagen final basada en **Nginx Alpine** (~30MB).


## 📋 Requisitos Previos

1. **Docker** y **Docker Compose** instalados en el host.

2. **Volumen Global**: Crear el volumen persistente para el store de pnpm (se hace una sola vez):

	```bash
	docker volume create pnpm_shared_store
	```


## 🚀 Guía de Inicio Rápido

1. **Inicializar un nuevo proyecto**

	Ejecuta este comando en la carpeta del proyecto para crear la subcarpeta app/ donde estaran los archivos de la aplicación (esto descargará la imagen de Node y ejecutará el scaffolding de Vite):

	```bash
	docker run --rm \
	  -v $(pwd):/work \
	  -v pnpm_shared_store:/pnpm/store \
	  -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
	  -w /work node:24.12.0-alpine3.22 \
	  sh -c "corepack enable && pnpm create vite app --template react-ts --yes && pnpm install --dir app --store-dir /pnpm/store"
	```

2. **Levantar Entorno de Desarrollo**

	Una vez creado el proyecto, levanta los servicios:

	```bash
	docker-compose up
	```

	Accede a la aplicación en: [http://localhost:5173](http://localhost:5173)

	> [!TIP]
	> Si los cambios en el código no se reflejan automáticamente (Hot Reload), asegúrate de que tu `vite.config.ts` incluya la configuración de `watch` con `usePolling: true` (ya configurado vía variables de entorno en el `docker-compose.yml`).

3. **Instalar nuevas dependencias**

	Para añadir paquetes sin salir del entorno Docker (ejemplo: ```axios```):

	```bash
	docker-compose exec app-react pnpm add axios
	```

4. **Construir Imagen de Producción**

	Para generar la imagen final lista para ser desplegada en cualquier servidor:

	```bash
	docker build --target production -t nombre-de-tu-app:latest .
	```


## 📂 Estructura del Proyecto

* ```Dockerfile```: Configuración multi-etapa (Desarrollo y Producción).

* ```docker-compose.yml```: Orquestador para el entorno de desarrollo y volúmenes.

* ```.dockerignore```: Optimización de contexto para construcción de imágenes.

* ```.gitignore```: Reglas específicas para evitar subir basura de Docker/pnpm a GitHub.


## 🧹 Limpieza y Mantenimiento

* **Detener contenedores**: ```docker-compose down```

* **Limpiar módulos del contenedor**: ```docker-compose down -v``` (Elimina volúmenes locales del proyecto, pero mantiene el ```pnpm_shared_store```).

* **Limpiar Store Global**: Si deseas liberar espacio de todas las librerías descargadas: ```docker volume rm pnpm_shared_store```.


## 📜 Licencia

Este proyecto está bajo la Licencia MIT. Siéntete libre de usarlo, modificarlo y distribuirlo.


## ¿Cómo usar esta plantilla?

1. Haz clic en el botón **"Use this template"** en GitHub.

2. Clona tu nuevo repositorio.

3. Sigue la **Guía de Inicio Rápido**.
