{ lib, appimageTools, src, pname ? "freecad-weekly", version ? "weekly" }:

let
  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      # Configure XKB config root and allow native Wayland with X11 fallback
      substituteInPlace $out/AppRun \
        --replace-fail '# export QT_XKB_CONFIG_ROOT=''${HERE}/usr/lib' 'export QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb; export XKB_CONFIG_ROOT=/usr/share/X11/xkb' \
        --replace-fail 'export QT_QPA_PLATFORM=xcb' ': "''${QT_QPA_PLATFORM:=wayland;xcb}"; export QT_QPA_PLATFORM'
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version src;
  contents = appimageContents;

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
