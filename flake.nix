{
  description = "Yandex Browser flake for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }:

    let

      stableFile = ./json/yandex-browser-stable.json;
      betaFile = ./json/yandex-browser-beta.json;

      getInfo = with builtins; file: fromJSON (readFile file);
      getName = file: let
        info = getInfo file;
      in
        "${info.pname}-${info.version}";

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            (getName stableFile)
            (getName betaFile)
          ];
        };
      };

      python = pkgs.python3.withPackages (ps: with ps; [
        requests
        beautifulsoup4
      ]);

      packages = {
        yandex-browser-beta = pkgs.callPackage ./package (getInfo betaFile);
        yandex-browser-stable = pkgs.callPackage ./package (getInfo stableFile);
      };

    in

    {

      packages.x86_64-linux = {
        inherit (packages) yandex-browser-stable yandex-browser-beta;
      };

      nixosModules = {
        system = import ./modules/nixos/default.nix packages;
        home-manager = import ./modules/home-manager packages;
      };

      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = [
          python
        ];
      };

      apps.x86_64-linux = {
        update_browser = {
          type = "app";
          program = toString (pkgs.writeScript "update_browser" ''
            #!/usr/bin/env bash
            set -e
            set -x

            ${python}/bin/python3 update/update.py
          '');
        };
        update_codecs = {
          type = "app";
          program = toString (pkgs.writeScript "update_codecs" ''
            #!/usr/bin/env bash
            set -e
            set -x

            export STRINGS_CMD=${pkgs.binutils}/bin/stings
            export STABLE=${packages.yandex-browser-stable}
            export BETA=${packages.yandex-browser-beta}
            ${python}/bin/python3 update/codecs.py
          '');
        };
      };

    };

}
