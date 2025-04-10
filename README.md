# 🚌 Bus App - Despliegue Automático de Microservicios con Vagrant + Ansible + Docker Swarm

Este proyecto automatiza el despliegue de una aplicación de microservicios utilizando **Vagrant**, **Ansible** y **Docker Swarm**. Con solo ejecutar `vagrant up`, se levantan dos máquinas virtuales (Manager y Worker), se instalan sus dependencias, se configuran, y se lanza la aplicación sin necesidad de intervención manual.

---

## 📦 ¿Qué hace este proyecto?

- Crea una arquitectura distribuida con dos nodos (Manager y Worker).
- Automatiza la instalación de Docker y dependencias vía Ansible.
- Inicializa Docker Swarm y une al Worker.
- Clona el repositorio de la app y construye las imágenes.
- Despliega automáticamente los servicios con `docker stack deploy`.
- Permite acceder directamente a la app vía navegador web.

---

## 🧱 Arquitectura y Construcción

### 🖥️ Sistema base: macOS

Todo el desarrollo y pruebas se realizaron en macOS. La infraestructura se basa en:

- Vagrant para crear máquinas virtuales.
- VirtualBox como proveedor.
- Ansible para la automatización.
- Docker y Docker Swarm como motor de contenedores.


### 🧩 Detalle de las máquinas virtuales

- **principal**: Nodo Manager (IP: `192.168.33.10`)
- **esclavo**: Nodo Worker (IP: `192.168.33.11`)

Cada máquina recibe su playbook específico:

| Máquina   | IP              | Rol     | Playbook asignado       |
|-----------|------------------|----------|---------------------------|
| principal | 192.168.33.10    | Manager  | `playbook_manager.yml`   |
| esclavo   | 192.168.33.11    | Worker   | `playbook_worker.yml`    |

Ambos comparten tareas comunes del archivo `playbook_common.yml`.


### 📜 Explicación de los Playbooks de Ansible

El proceso de automatización está dividido en tres playbooks principales:

---

### 🔁 `playbook_common.yml` – Configuración Común para Todos los Nodos

Este playbook se aplica **tanto al nodo Manager como al Worker**. Su objetivo es preparar el entorno base para que ambos nodos puedan operar con Docker Swarm y ejecutar los servicios de la aplicación.

**Tareas principales:**

- Actualiza el sistema (`apt update`)
- Instala dependencias básicas: `curl`, `git`, `python3-pip`, etc.
- Instala Docker y Docker Compose manualmente
- Clona el repositorio del proyecto
- Descarga todas las imágenes de Docker desde Docker Hub
- Añade el usuario `vagrant` al grupo `docker` para poder ejecutar Docker sin `sudo`
- Define variables reutilizables como:
  - URL del repositorio
  - Directorio de destino (`/vagrant/bus-app`)
  - Directorio donde se construye la app
  - Lista de imágenes a descargar
  - Dirección IP del nodo manager (`192.168.33.10`)

> ✅ Este playbook **centraliza la lógica común** para evitar duplicación entre nodos.

---

### 👑 `playbook_manager.yml` – Configuración del Nodo Principal (Manager)

Este playbook **importa el común** y luego ejecuta tareas **específicas del nodo principal**:

**Tareas clave:**

- Clona (o actualiza) el repositorio de la aplicación desde GitHub.
- Construye las imágenes usando `docker compose build`.
- Inicializa Docker Swarm como **manager**, anunciándose en `192.168.33.10`.
- Obtiene el **comando de join para los workers** y lo guarda en un archivo (`unir_swarm.txt`) compartido por Vagrant.
- Despliega todos los servicios usando `docker stack deploy`.
- Escala automáticamente los servicios a 3 réplicas cada uno para testear balanceo de carga.

> 🧠 Este nodo es el **cerebro del sistema**: crea la red, define los servicios y permite visualizar la app desde el navegador.

---

### ⚙️ `playbook_worker.yml` – Configuración del Nodo Secundario (Worker)

Este playbook también **importa el común** y luego ejecuta tareas para **unirse al cluster Swarm** creado por el manager.

**Tareas clave:**

- Espera a que se genere el archivo `unir_swarm.txt` (que contiene el comando `docker swarm join`).
- Lee ese comando desde el archivo y lo ejecuta para unirse como **worker**.
- También ejecuta `docker compose build` para preparar localmente las imágenes (aunque no lanza servicios por su cuenta).

> 🧩 Este nodo aporta capacidad de procesamiento al cluster y ejecuta contenedores cuando el manager lo requiere.

---

### 🔗 Relación entre los playbooks

| Orden de ejecución (implícito por Vagrant) | ¿Qué se hace?                            |
|--------------------------------------------|------------------------------------------|
| 1. `playbook_common.yml`                   | Prepara el entorno base en ambos nodos   |
| 2. `playbook_manager.yml`                  | Inicia el Swarm y lanza los servicios    |
| 3. `playbook_worker.yml`                   | Se une al Swarm y está listo para servir |

Cada uno de estos playbooks está **pensado para automatizar completamente** el despliegue de la aplicación en sus respectivos roles, sin necesidad de acceso manual.

---
### 🐳 Docker Compose – Definición del Stack de Servicios

El archivo `docker-compose.yml` define los **servicios que componen la aplicación distribuida** desplegada en Docker Swarm. Está orientado a una arquitectura de microservicios, y se aprovechan las capacidades del modo Swarm para escalabilidad y redes superpuestas.

### 🔧 Versión
```yaml
version: "3.9"

---

## 🚀 ¿Cómo ejecutar el proyecto?

### 1. Clonar el repositorio

```bash
git clone https://github.com/Revengers777/bus-app.git
cd bus-app
vagrant up
**acceso a la app en tu navegador**
http://192.168.33.10

