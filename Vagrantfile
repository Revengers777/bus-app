Vagrant.configure("2") do |config|
  # Box base
  config.vm.box = "bento/ubuntu-22.04"

  # Script común para instalar Docker
  docker_install_script = <<-SHELL
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker vagrant
  SHELL

  # Carpeta sincronizada (con permisos de lectura y escritura)
  shared_folder_host = "."
  shared_folder_guest = "/vagrant"

  # Nodo principal (antes manager)
  config.vm.define "principal" do |principal|
    principal.vm.hostname = "swarm-principal"
    principal.vm.network "private_network", ip: "192.168.33.10"
    principal.vm.network "forwarded_port", guest: 80, host: 8080
    principal.vm.provider "virtualbox" do |vb|
      vb.name = "swarm-principal"
      vb.memory = 1024
    end
    principal.vm.provision "shell", inline: docker_install_script
    principal.vm.synced_folder shared_folder_host, shared_folder_guest, mount_options: ["dmode=775", "fmode=775"]
  end

  # Nodo esclavo (antes nodo1)
  config.vm.define "esclavo" do |esclavo|
    esclavo.vm.hostname = "swarm-esclavo"
    esclavo.vm.network "private_network", ip: "192.168.33.11"
    esclavo.vm.provider "virtualbox" do |vb|
      vb.name = "swarm-esclavo"
      vb.memory = 1024
    end
    esclavo.vm.provision "shell", inline: docker_install_script
    esclavo.vm.synced_folder shared_folder_host, shared_folder_guest, mount_options: ["dmode=775", "fmode=775"]
  end
end
