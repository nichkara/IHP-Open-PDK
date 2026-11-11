{
  description = "KLayout 0.30.5";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          klayout = pkgs.stdenv.mkDerivation {
            pname = "klayout";
            version = "0.30.5";

            src = pkgs.fetchFromGitHub {
              owner = "KLayout";
              repo = "klayout";
              rev = "dacb3230d5b4780d2c28c9c185383486dcbc8edf";
              hash = pkgs.lib.fakeHash;
            };

            nativeBuildInputs = with pkgs; [
              pkg-config
              qt6.wrapQtAppsHook
              makeWrapper
            ];

            buildInputs = with pkgs; [
              qt6.qtbase
              qt6.qttools
              qt6.qtsvg
              qt6.qtmultimedia

              zlib
              libgit2

              ruby
              python3
            ];

            dontConfigure = true;

            buildPhase = ''
              runHook preBuild

              ./build.sh \
                -qmake ${pkgs.qt6.qtbase}/bin/qmake \
                -build build \
                -bin "$out" \
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
          };
        in
        {
          default = klayout;
          klayout = klayout;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/klayout";
        };

        klayout = {
          type = "app";
          program = "${self.packages.${system}.klayout}/bin/klayout";
        };
      });
    };
}
