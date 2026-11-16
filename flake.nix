{
  description = "IHP PDK supported tools in tested and nightly versions.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Alle Werkzeuge für ein gegebenes pkgs-Set bauen
      mkTools = pkgs: {
        klayout = import ./nix/klayout.nix { inherit pkgs; };
        xschem = import ./nix/xschem.nix { inherit pkgs; };
      };
    in
    {
      packages = forAllSystems (
        system:
        let
          tools = mkTools nixpkgs.legacyPackages.${system};
        in
        tools // { default = tools.klayout; }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = builtins.attrValues (mkTools pkgs);
          };
        }
      );
    };
}
