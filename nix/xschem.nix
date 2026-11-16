{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "xschem";
  version = "3.4.6";

  src = pkgs.fetchFromGitHub {
    owner = "StefanSchippers";
    repo = "xschem";
    rev = "da6532d8d80f5068d12cf4e0ca14e71fcda35cc0";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = with pkgs; [
    bash
    which
    coreutils
    pkg-config

    makeWrapper
  ];

  postPatch = "";

  buildInputs = with pkgs; [
    libx11
    flex
    libxrender
    libxcb
    cairo
    tcl-8_6
    tk-8_6
    libxpm
    libjpeg
    bison
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    ./configure --prefix=$out
    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    test -x "$out/bin/xschem"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "A schematic editor for VLSI/Asic/Analog custom designs, netlist backends for VHDL, Spice and Verilog. The tool is focused on hierarchy and parametric designs, to maximize circuit reuse.";
    homepage = "http://repo.hu/projects/xschem/index.html";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    mainProgram = "xschem";
  };
}
