# -*- mode: ruby -*- 
# vi: set ft=ruby : vsa
Vagrant.configure(2) do |config| 
    config.vm.box = "ubuntu/focal64" 
    config.vm.box_version = "20230719.0.0" 
    config.vm.provider "virtualbox" do |v| 
    v.memory = 512 
    v.cpus = 2 
    config.vbguest.auto_update = false
    end 
    config.vm.define "bashscript" do |bashscript| 
        bashscript.vm.box_check_update = false
        bashscript.vm.network "private_network", ip: "192.168.50.10",  virtualbox__intnet: "net1" 
        bashscript.vm.hostname = "bashscript" 
        bashscript.vm.provision "file", source: "./script.sh", destination: "/tmp/script.sh"
        bashscript.vm.provision "file", source: "./access1.log", destination: "/tmp/access1.log"
        bashscript.vm.provision "shell", inline: <<-SHELL
	    chmod +x /tmp/script.sh
        apt-get update
        echo "postfix postfix/mailname string test@altemans.ru" | debconf-set-selections
        echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
        DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
        apt-get install mailutils -y
        echo "* * * * * root /tmp/script.sh" | tee -a /etc/crontab
        sed -i 's/inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf
        systemctl restart postfix
        SHELL
    end 
   end 
   
   