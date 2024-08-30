{
  description = "Minimal session variable manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs systems;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;
    in {
      default = self.packages.${system}.session;
      session = pkgs.stdenv.mkDerivation {
        name = "session";
        pname = "session";
        src = ./.;

        nativeBuildInputs = with pkgs; [ makeWrapper ];

        installPhase = ''
          mkdir -p $out/bin
          install -t $out/bin -m 755 session ttyuserdo sessiontty
        '';

        postFixup = with pkgs; ''
          for bin in $out/bin/*; do
            wrapProgram $bin \
              --suffix PATH : ${lib.makeBinPath [
                coreutils
                sudo
                gawk
                gnugrep
                bash
                procps
              ]}
          done
        '';
      };
    });
  };
}
