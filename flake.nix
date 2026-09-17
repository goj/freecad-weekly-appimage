{
  description = "A Nix flake packaging the official weekly FreeCAD AppImage for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Upstream weekly AppImages (hashes automatically managed in flake.lock)
    freecad-appimage-x86_64 = {
      url = "https://github.com/FreeCAD/FreeCAD/releases/download/weekly-2026.09.16/FreeCAD_weekly-2026.09.16-Linux-x86_64.AppImage";
      flake = false;
    };
    freecad-appimage-aarch64 = {
      url = "https://github.com/FreeCAD/FreeCAD/releases/download/weekly-2026.09.16/FreeCAD_weekly-2026.09.16-Linux-aarch64.AppImage";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { pkgs, system, ... }:
        let
          srcs = {
            x86_64-linux = inputs.freecad-appimage-x86_64;
            aarch64-linux = inputs.freecad-appimage-aarch64;
          };

          version = "weekly-2026.09.16";

          freecad = pkgs.callPackage ./package.nix {
            src = srcs.${system};
            pname = "freecad-weekly";
            inherit version;
          };

          # Coexists alongside stable FreeCAD with distinct desktop entry and command name
          freecad-dev = freecad.overrideAttrs (oldAttrs: {
            pname = "freecad-dev";
            extraInstallCommands = (oldAttrs.extraInstallCommands or "") + ''
              ln -s $out/bin/freecad-weekly $out/bin/freecad-dev

              cp $out/share/applications/org.freecad.FreeCAD.desktop $out/share/applications/org.freecad.FreeCAD.dev.desktop
              substituteInPlace $out/share/applications/org.freecad.FreeCAD.dev.desktop \
                --replace-fail "Exec=freecad-weekly" "Exec=freecad-dev" \
                --replace-fail "Name=FreeCAD" "Name=FreeCAD (dev)"
            '';
          });
        in
        {
          packages = {
            inherit freecad freecad-dev;
            default = freecad;
          };

          apps.update = {
            type = "app";
            program = "${pkgs.writeShellApplication {
              name = "update";
              runtimeInputs = [ pkgs.curl pkgs.jq pkgs.coreutils pkgs.gnused pkgs.nix ];
              text = builtins.readFile ./update.sh;
            }}/bin/update";
          };
        };
    };
}
