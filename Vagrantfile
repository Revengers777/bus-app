Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  # Paquetes comunes para todas las VMs
  common_packages = <<-SHELL
    apt-get update
    apt-get install -y curl python3-pip jq git net-tools
    pip3 install ansible
  SHELL

  # Docker y Docker Compose
  docker_install = <<-SHELL
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker vagrant
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  SHELL

  # Carpeta compartida con permisos RW
  shared_folder_host = "."
  shared_folder_guest = "/vagrant"

  # Nodo principal (Manager)
  config.vm.define "principal" do |principal|
    principal.vm.hostname = "swarm-principal"
    principal.vm.network "private_network", ip: "192.168.33.10"
    principal.vm.network "forwarded_port", guest: 80, host: 8080
    principal.vm.provider "virtualbox" do |vb|
      vb.name = "swarm-principal"
      vb.memory = 1024
    end
    principal.vm.provision "shell", inline: common_packages
    principal.vm.provision "shell", inline: docker_install
    principal.vm.provision "ansible_local" do |ansible|
      ansible.compatibility_mode = "auto"
      ansible.provisioning_path = "/vagrant/"
      ansible.playbook = "ansible/playbook_manager.yml"  # Usamos el playbook para el nodo manager
      ansible.limit = "principal"
      ansible.install = false
      ansible.verbose = "v"
      ansible.extra_vars = { ansible_python_interpreter: '/usr/bin/python3' }
    end
    principal.vm.synced_folder shared_folder_host, shared_folder_guest, mount_options: ["rw"]
  end

  # Nodo esclavo (Worker)
  config.vm.define "esclavo" do |esclavo|
    esclavo.vm.hostname = "swarm-esclavo"
    esclavo.vm.network "private_network", ip: "192.168.33.11"
    esclavo.vm.provider "virtualbox" do |vb|
      vb.name = "swarm-esclavo"
      vb.memory = 1024
    end
    esclavo.vm.provision "shell", inline: common_packages
    esclavo.vm.provision "shell", inline: docker_install
    esclavo.vm.provision "ansible_local" do |ansible|
      ansible.compatibility_mode = "auto"
      ansible.provisioning_path = "/vagrant/"
      ansible.playbook = "ansible/playbook_worker.yml"  # Usamos el playbook para el nodo worker
      ansible.limit = "esclavo"
      ansible.install = false
      ansible.verbose = "v"
      ansible.extra_vars = { ansible_python_interpreter: '/usr/bin/python3' }
    end
    esclavo.vm.synced_folder shared_folder_host, shared_folder_guest, mount_options: ["rw"]
  end
end

