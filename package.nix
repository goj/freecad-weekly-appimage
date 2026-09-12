{ lib, appimageTools, src, pname ? "freecad-weekly", version ? "weekly" }:

let
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Symlink primary binary as freecad
    ln -s $out/bin/${pname} $out/bin/freecad

    # Install desktop entry and icons
    install -m 444 -D ${appimageContents}/org.freecad.FreeCAD.desktop $out/share/applications/org.freecad.FreeCAD.desktop
    install -m 444 -D ${appimageContents}/org.freecad.FreeCAD.svg $out/share/icons/hicolor/scalable/apps/org.freecad.FreeCAD.svg

    # Ensure desktop file points to the wrapped executable
    substituteInPlace $out/share/applications/org.freecad.FreeCAD.desktop \
      --replace-fail "Exec=AppRun" "Exec=${pname}"
  '';

  meta = with lib; {
    description = "Official weekly pre-built AppImage of FreeCAD wrapped for NixOS";
    homepage = "https://www.freecad.org";
    license = licenses.lgpl2Plus;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = pname;
  };
}
