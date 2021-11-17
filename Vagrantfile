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
        app.vm.hostname = "webserver#{i+101}"
        app.vm.network :private_network, ip: "192.168.0.#{i+101}"
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
        haproxy.vm.network "private_network", ip: "192.168.0.100"

        haproxy.vm.provision "shell", inline: <<-SHELL
          systemctl disable firewalld.service
          systemctl stop firewalld.service
          apt-get -y install haproxy
          mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.org
          systemctl enable haproxy.service
        SHELL
        
        haproxy.vm.provision "file", source: "haproxy.cfg", destination: "~/haproxy.cfg"

        n.times do |i|
          ip = "192.168.50.#{100+i+1}"
          haproxy.vm.provision "shell", inline: <<-SHELL
          echo "    server  app#{i+1} #{ip}:80 check" >> /home/vagrant/haproxy.cfg
          SHELL
        end

        haproxy.vm.provision "shell", inline: <<-SHELL
          mv /home/vagrant/haproxy.cfg /etc/haproxy/
          systemctl start haproxy.service
        SHELL
    end
end

