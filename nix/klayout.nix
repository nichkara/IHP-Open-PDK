{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "klayout";
  version = "0.30.5";

  src = pkgs.fetchFromGitHub {
    owner = "KLayout";
    repo = "klayout";
    rev = "dacb3230d5b4780d2c28c9c185383486dcbc8edf";
    hash = "sha256-WigRictn6CxOPId2YitlEm43vEw+dSRWdoareD9HtMc=";
  };

  nativeBuildInputs = with pkgs; [
    bash
    which
    coreutils
    pkg-config

    qt5.wrapQtAppsHook
    qt5.qttools
    makeWrapper
  ];

  postPatch = ''
    patchShebangs build.sh
  '';

  buildInputs = with pkgs; [
    qt5.qtbase
    qt5.qtsvg
    qt5.qtmultimedia
    qt5.qtxmlpatterns

    zlib
    libgit2

    ruby
    python3
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p "$out/bin"

    ./build.sh \
      -qmake ${pkgs.qt5.qtbase.dev}/bin/qmake \
      -build build \
      -bin "$out/bin" \
      -option "-j$NIX_BUILD_CORES"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    test -x "$out/bin/klayout"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "KLayout IC layout viewer and editor";
    homepage = "https://www.klayout.de/";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    mainProgram = "klayout";
  };
}
