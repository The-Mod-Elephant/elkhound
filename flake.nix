{
  description = "elkhound";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/2cd3cac16691a933e94276f0a810453f17775c28";
  };
  outputs = { self, nixpkgs }:
    let systems = [
      "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            name = "elkhound-shell";
            src = self;
            # Libs
            buildInputs = with pkgs; [
              bison
              cmake
              flex
              gnumake
            ];
            # Tools
            nativeBuildInputs = with pkgs; [
              direnv
              git
              yamllint
            ];
            # Env
            shellHook = ''
            '';
          };
        });
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in pkgs.stdenv.mkDerivation {
          pname = "elkhound";
          version = "1.0";

          src = ./src;

          nativeBuildInputs = with pkgs; [
            bison
            cmake
            flex
            gnumake
          ];

          buildInputs = with pkgs; [
            git
          ];

          configurePhase = ''
            cmake -Wno-dev -DEXTRAS=OFF -DOCAML=OFF -B $out/build -D CMAKE_BUILD_TYPE=Release
          '';

          buildPhase = ''
            make -j$(nproc) -C $out/build
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp --preserve=mode -r $out/build/elkhound/elkhound $out/bin/elkhound
            rm -rf $out/build
          '';
          enableParallelBuilding = true;
        }
      );
    };
}
