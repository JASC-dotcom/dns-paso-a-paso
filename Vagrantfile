# -*- mode: ruby -*-
# Read the variables from config/vars.env
vars = File.readlines(File.join(__dir__, "config", "vars.env"))
           .map(&:strip).reject { |l| l.empty? || l.start_with?("#") }
           .map { |l| l.split("=", 2) }.to_h.transform_values { |v| v.delete('"') }

PRIMARY_IP   = "#{vars['NET']}.#{vars['PRIMARY_LAST']}"
SECONDARY_IP = "#{vars['NET']}.#{vars['SECONDARY_LAST']}"

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.synced_folder ".", "/vagrant"

  # Primary (master) server
  config.vm.define "primario" do |p|
    p.vm.hostname = "debian"
    p.vm.network "private_network", ip: PRIMARY_IP
    p.vm.provision "shell", path: "config/01-primario-installation.sh"
    p.vm.provision "shell", path: "config/02-primario-options.sh"
    p.vm.provision "shell", path: "config/03-primario-zones.sh"
    p.vm.provision "shell", path: "config/06-primario-transfers.sh"
    p.vm.provision "shell", inline: "bash /vagrant/test.sh primario"
  end

  # Secondary (slave) server: it is created after the primary
  config.vm.define "secundario" do |s|
    s.vm.hostname = "debian2"
    s.vm.network "private_network", ip: SECONDARY_IP
    s.vm.provision "shell", path: "config/04-secundario-installation.sh"
    s.vm.provision "shell", path: "config/05-secundario-zones.sh"
    s.vm.provision "shell", inline: "bash /vagrant/test.sh secundario"
  end
end
