Vagrant.configure(2) do |config|

    config.vm.box = "debian/jessie64"

    config.vm.network "private_network", ip: "192.168.33.34"

    config.vm.synced_folder ".", "/vagrant", type: "virtualbox", :mount_options => [ 'dmode=775', 'fmode=775' ]

    config.vm.provision "shell" do |s|
        s.path = "vagrant-provision.sh"
    end

    config.vm.provider "virtualbox" do |vb|
        # Display the VirtualBox GUI when booting the machine
        # vb.gui = true

        # Install/update VirtualBox guest additions
        # Requires Vagrant plugin: https://github.com/dotless-de/vagrant-vbguest
        config.vbguest.auto_update = true
    end
end
