#!/bin/sh
set -e

if [ "$1" = "--diff" ] || [ "$1" = "-d" ]; then
    echo "Generating diff and saving to conf.diff..."
    diff -u /etc/nixos/configuration.nix configuration.nix > conf.diff || true
    echo "Diff saved to conf.diff"
    exit 0
fi

echo "DIFF"
diff -u /etc/nixos/configuration.nix configuration.nix || true

echo ""
read -p "Are you sure? (Y/n): " response

if [ -z "$response" ] || [ "$response" = "Y" ] || [ "$response" = "y" ]; then
    echo "Applying configuration..."
    cp configuration.nix /etc/nixos/.
    nixos-rebuild switch
else
    echo "Elo xD"
    exit 1
fi