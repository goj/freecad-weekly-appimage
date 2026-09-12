#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest FreeCAD weekly release..."
LATEST_TAG=$(curl -s "https://api.github.com/repos/FreeCAD/FreeCAD/releases" | jq -r '[.[] | select(.tag_name | startswith("weekly-"))][0].tag_name')

if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" = "null" ]; then
  echo "Error: Failed to find latest weekly release tag." >&2
  exit 1
fi

echo "Latest upstream weekly tag: $LATEST_TAG"

CURRENT_TAG=$(grep -oE 'weekly-[0-9]{4}\.[0-9]{2}\.[0-9]{2}' flake.nix | head -n 1 || true)
echo "Current tag in flake.nix: $CURRENT_TAG"

if [ "$CURRENT_TAG" = "$LATEST_TAG" ]; then
  echo "Already up to date ($CURRENT_TAG)."
  exit 0
fi

echo "Updating flake.nix to $LATEST_TAG..."
sed -i "s|${CURRENT_TAG}|${LATEST_TAG}|g" flake.nix

echo "Updating flake inputs..."
nix flake lock --update-input freecad-appimage-x86_64 --update-input freecad-appimage-aarch64

echo "Update complete: $CURRENT_TAG -> $LATEST_TAG"
