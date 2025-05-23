HOSTNAME = $(shell hostname)
USER = $(shell whoami)

ifndef HOSTNAME
 $(error Hostname unknown)
endif

ifndef USER
 $(error User unknown)
endif

help:
	@echo "Available targets:"
	@echo "  home       - Switches the home-manager configuration. Use 'light' to override darkmode_flag."
	@echo "  home_build - Builds and switches the home-manager configuration, then reboots the system."
	@echo "  os         - Rebuilds the NixOS configuration."
	@echo "  iso        - Builds an ISO image of the NixOS configuration."
	@echo "  vm         - Builds a VM of the NixOS configuration."

home:
ifdef light
	home-manager switch -b backup --flake ~/dev/nixos-config/#${USER}@${HOSTNAME} --override-input darkmode_flag github:boolean-option/false
else
	home-manager switch -b backup --flake ~/dev/nixos-config/#${USER}@${HOSTNAME}
endif
# FIXME No idea why I have to issue `nix profile list` first, if I don't, I get
# no suitable profile found from home-manager?
home_build:
	sudo chown -R ripxorip:users /home/ripxorip
	nix profile list
	home-manager build -b backup --flake ~/dev/nixos-config/#${USER}@${HOSTNAME}
	-home-manager switch -b backup --flake ~/dev/nixos-config/#${USER}@${HOSTNAME}
	echo "Rebooting in 3 seconds"
	sleep 3
	sudo reboot
os:
	sudo nixos-rebuild switch --flake ~/dev/nixos-config/#${HOSTNAME}
iso:
	nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage
vm:
	nix build .#nixosConfigurations.ripxovm_qcow
