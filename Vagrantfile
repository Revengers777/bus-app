Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  # Detectar si el host es Windows
  is_windows = !!(RUBY_PLATFORM =~ /mingw|mswin/)

  # Script común
  common_packages = <<-SHELL
    apt-get update
    apt-get install -y curl python3-pip jq git net-tools
    pip3 install ansible
  SHELL

  # Instalación de Docker y Docker Compose
  docker_install = <<-SHELL
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker vagrant

    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  SHELL

  shared_folder_host = "."
  shared_folder_guest = "/vagrant"

  # Config para cada VM
  ["principal", "esclavo"].each_with_index do |name, i|
    config.vm.define name do |node|
      node.vm.hostname = "swarm-#{name}"
      node.vm.network "private_network", ip: "192.168.33.1#{i}"

      # Solo el principal expone el puerto 80
      if name == "principal"
        node.vm.network "forwarded_port", guest: 80, host: 8080
      end

      node.vm.provider "virtualbox" do |vb|
        vb.name = "swarm-#{name}"
        vb.memory = 1024
      end

      node.vm.provision "shell", inline: common_packages
      node.vm.provision "shell", inline: docker_install

      if is_windows
        # Windows: usar ansible dentro de la VM
        node.vm.provision "shell", inline: <<-SHELL
          cd /vagrant/ansible
          ansible-playbook playbook_common.yml -i inventory.yml
        SHELL
      else
        # No Windows: Ansible como provisioner externo
        node.vm.provision "ansible" do |ansible|
          ansible.playbook = "ansible/playbook_common.yml"
        end
      end

      node.vm.synced_folder shared_folder_host, shared_folder_guest, mount_options: ["rw"]
    end
  end
end


    esclavo.vm.synced_folder shared_folder_host, shared_folder_guest, mount_options: ["rw"]
  end
end

    esclavo.vm.synced_folder shared_folder_host, shared_folder_guest, mount_options: ["rw"]
  end
end
