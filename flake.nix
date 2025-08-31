{
  description = "HONK";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      quickshell,
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
          qs = quickshell.packages.${system}.default.override {
            withX11 = false;
            withI3 = false;
          };

          runtimeDeps = [ ];

          fontconfig = pkgs.makeFontsConf {
            fontDirectories = [ ];
          };
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "honklet";
            version = self.rev or self.dirtyRev or "dirty";
            src = ./.;

            nativeBuildInputs = [
              pkgs.gcc
              pkgs.makeWrapper
              pkgs.qt6.wrapQtAppsHook
            ];
            buildInputs = [
              qs
              pkgs.xkeyboard-config
              pkgs.qt6.qtbase
            ];
            propagatedBuildInputs = runtimeDeps;

            installPhase = ''
              mkdir -p $out/share/honklet
              cp -r ./* $out/share/honklet

              makeWrapper ${qs}/bin/qs $out/bin/honklet \
                --prefix PATH : "${pkgs.lib.makeBinPath runtimeDeps}" \
                --set FONTCONFIG_FILE "${fontconfig}" \
                --add-flags "-p $out/share/honklet"
            '';

            meta = {
              description = "HONK";
              homepage = "https://github.com/hannahfluch/honklet";
              license = pkgs.lib.licenses.mit;
              mainProgram = "honklet";
            };
          };
        }
      );

      defaultPackage = eachSystem (system: self.packages.${system}.default);
    };
}
