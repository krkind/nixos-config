HOSTNAME = $(shell hostname)
USER = $(shell whoami)

ifndef HOSTNAME
 $(error Hostname unknown)
endif

ifndef USER
 $(error User unknown)
endif

.PHONY: help home home_build os iso vm index test-comma

help:
	@printf "\n"
	@printf "\033[1;36m╔════════════════════════════════════════════════════════════════╗\033[0m\n"
	@printf "\033[1;36m║\033[0m    \033[1;35mRipxonix NixOS & Home Manager Configuration\033[0m          \033[1;36m║\033[0m\n"
	@printf "\033[1;36m╚════════════════════════════════════════════════════════════════╝\033[0m\n"
	@printf "\n"
	@printf "\033[1;33mUsage:\033[0m make <target>\n"
	@printf "\n"
	@printf "\033[1;33mTargets:\033[0m\n"
	@printf "  \033[1;32mhome\033[0m              Apply home-manager configuration\n"
	@printf "                    (use '\033[1;32mmake home light\033[0m' for light mode)\n"
	@printf "\n"
	@printf "  \033[1;32mhome_build\033[0m        Build & apply home-manager, then reboot\n"
	@printf "\n"
	@printf "  \033[1;32mos\033[0m                Rebuild & switch NixOS configuration\n"
	@printf "\n"
	@printf "  \033[1;32miso\033[0m               Build an ISO image\n"
	@printf "\n"
	@printf "  \033[1;32mvm\033[0m                Build a VM image\n"
	@printf "\n"
	@printf "  \033[1;32mindex\033[0m             Build nix-index database (for '\033[1;36m,\033[0m' command)\n"
	@printf "\n"
	@printf "  \033[1;32mtest-comma\033[0m        Test comma with: \033[1;36m, cowsay \"Hello\"\033[0m\n"
	@printf "\n"
	@printf "  \033[1;32mhelp\033[0m              Show this help message\n"
	@printf "\n"

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
	sudo nixos-rebuild switch --flake .#${HOSTNAME}
iso:
	nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage
vm:
	nix build .#nixosConfigurations.ripxovm_qcow

index:
	nix-index

test-comma:
	, cowsay "Hello"
