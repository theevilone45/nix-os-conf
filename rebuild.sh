#!/bin/sh
set -e

cp configuration.nix /etc/nixos/.
nixos-rebuild switch