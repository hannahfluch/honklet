{
  description = "HONK";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      packages = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = nixpkgs.lib;
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "honklet";
            version = self.rev or self.dirtyRev or "dirty";
            src = ./.;

            nativeBuildInputs = [
              pkgs.makeWrapper
            ];

            installPhase = ''
              mkdir -p $out/share/honklet
              cp -r ./* $out/share/honklet

              makeWrapper ${lib.getExe pkgs.quickshell} $out/bin/honklet \
                --add-flags "-p $out/share/honklet"
            '';

            meta = {
              description = "HONK";
              homepage = "https://github.com/hannahfluch/honklet";
              license = lib.licenses.mit;
              mainProgram = "honklet";
            };
          };
        }
      );

      defaultPackage = eachSystem (system: self.packages.${system}.default);
    };
}
