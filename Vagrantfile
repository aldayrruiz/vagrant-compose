# -*- mode: ruby -*-
# vi: set ft=ruby :

n = 2

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/focal64"

    n.times do |i|
      config.vm.define "app-#{i+1}" do |app|
        app.vm.provider :virtualbox do |vb_config|
          vb_config.name = "Web Server #{i+1} - lay4-hap1-web#{i+1}"
        end
        app.vm.synced_folder "wordpress", "/var/www/html"
        app.vm.hostname = "webserver#{i+1}"
        app.vm.network :private_network, ip: "192.168.56.#{i+101}"
        app.vm.provision :shell, path: "webserver.sh"
      end
    end
 
    # Configs for haproxy
    config.vm.define :haproxy do |haproxy|
        haproxy.vm.provider :virtualbox do |vb_config|
            vb_config.name = "HAProxy - lay4-hap1-lb"
        end
        haproxy.vm.hostname = "haproxy"
        haproxy.vm.network :forwarded_port, guest: 80, host: 8080
        haproxy.vm.network "private_network", ip: "192.168.56.100"

        haproxy.vm.provision "shell", inline: <<-SHELL
          apt-get update -y -qq
          apt-get install -y haproxy
          mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.org
          systemctl enable haproxy
        SHELL
        
        haproxy.vm.provision "file", source: "haproxy.cfg", destination: "~/haproxy.cfg"

        n.times do |i|
          ip = "192.168.56.#{100+i+1}"
          haproxy.vm.provision "shell", inline: <<-SHELL
          echo "server  app#{i+1} #{ip}:80 check" >> /home/vagrant/haproxy.cfg
          SHELL
        end

        haproxy.vm.provision "shell", inline: <<-SHELL
          mv /home/vagrant/haproxy.cfg /etc/haproxy/
          systemctl restart haproxy
        SHELL
    end

    # Config MySQL
    config.vm.define :database do |database|
      database.vm.provider :virtualbox do |vb_config|
        vb_config_name = "Database - lay5-hap1-db"
      end
      database.vm.hostname = "database"
      database.vm.network "private_network", ip: "192.168.56.25"
      database.vm.provision "shell", inline: <<-SHELL
        # Actualizar los paquetes instalados
        apt-get update
    
        # Instalar y configurar MySQL
        echo "mysql-server mysql-server/root_password password PASSWORD" | sudo debconf-set-selections
        echo "mysql-server mysql-server/root_password_again password PASSWORD" | sudo debconf-set-selections
        apt-get install -y mysql-server
        mysql -u root -p"PASSWORD" -e "CREATE DATABASE IF NOT EXISTS wordpress;"
        mysql -u root -p"PASSWORD" -e "CREATE USER IF NOT EXISTS 'wpuser' IDENTIFIED BY 'wppass';"
        mysql -u root -p"PASSWORD" -e "GRANT ALL ON wordpress.* TO 'wpuser';"
    
        # Permitir acceso a MySQL desde cualquier dirección
        service mysql restart
        sudo sed -i "0, /bind-address/{s/.*bind-address.*/bind-address = 0.0.0.0/}" /etc/mysql/mysql.conf.d/mysqld.cnf
      SHELL
    end
end
