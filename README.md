# FreeCAD Weekly AppImage Nix Flake

A lightweight Nix flake providing bleeding-edge weekly builds of [FreeCAD](https://www.freecad.org/) packaged directly from official upstream pre-compiled AppImages.

## Why this flake?

Building FreeCAD from source on NixOS takes **2–4 hours** and uses massive system resources. This flake wraps the official upstream weekly AppImage inside a Nix Bubblewrap FHS environment, giving you the latest FreeCAD development release with a **build time of ~2 seconds**.

## Usage

### Run directly
```bash
nix run github:goj/freecad-weekly-appimage
```

Or run the `freecad-dev` variant (configured with distinct desktop entry and executable name to coexist with stable FreeCAD):
```bash
nix run github:goj/freecad-weekly-appimage#freecad-dev
```

### Add to NixOS / Home Manager
In your `flake.nix`:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    freecad-weekly.url = "github:goj/freecad-weekly-appimage";
  };

  outputs = { self, nixpkgs, freecad-weekly, ... }: {
    # In your configuration:
    # environment.systemPackages = [ freecad-weekly.packages.${system}.default ];
  };
}
```

## Auto-Update

This repository contains a scheduled GitHub Actions workflow that checks for new upstream weekly releases every Thursday, updates `flake.nix` and `flake.lock`, verifies the build, and pushes updates automatically.
