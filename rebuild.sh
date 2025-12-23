#!/bin/sh
set -e

cp {configuration.nix,hardware-configuration.nix} /etc/nixos/.
nixos-rebuild switch