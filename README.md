# Ripxonix
Ripxorip's NixOS &amp; Home Manager Configurations

``````make
#################################################################################
#
#               88                                               88
#               ""                                               ""
#
#    8b,dPPYba, 88 8b,dPPYba, 8b,     ,d8 ,adPPYba,  8b,dPPYba,  88 8b,     ,d8
#    88P'   "Y8 88 88P'    "8a `Y8, ,8P' a8"     "8a 88P'   `"8a 88  `Y8, ,8P'
#    88         88 88       d8   )888(   8b       d8 88       88 88    )888(
#    88         88 88b,   ,a8" ,d8" "8b, "8a,   ,a8" 88       88 88  ,d8" "8b,
#    88         88 88`YbbdP"' 8P'     `Y8 `"YbbdP"'  88       88 88 8P'     `Y8
#                  88
#                  88
#
#################################################################################
``````

## Inspirations 🖋️
- Wimpy https://github.com/wimpysworld/nix-config
- Misterio77 https://github.com/Misterio77/nix-starter-configs

## Usage ⚒️
### Build the ISO 💿
`make iso`

### Rebuild the OS
make os

### Build flake
`sudo nixos-rebuild switch --flake .#krkindwork`

### Build home manager
`home-manager switch --flake .#kristian`
