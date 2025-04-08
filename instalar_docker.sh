#!/bin/bash

# Actualizar el índice de paquetes
sudo apt-get update -y

# Instalar dependencias necesarias para permitir el uso de repositorios HTTPS
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Descargar el script oficial de instalación de Docker
curl -fsSL https://get.docker.com -o get-docker.sh

# Ejecutar el script de instalación de Docker
sudo sh get-docker.sh

# Añadir al usuario 'vagrant' al grupo 'docker' para permitir ejecutar comandos Docker sin sudo
sudo usermod -aG docker vagrant

# Verificar la instalación de Docker
docker --version
