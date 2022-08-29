{
  description = "Yandex Browser flake for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
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
            (getName ./json/yandex-browser-stable.json)
            (getName ./json/yandex-browser-beta.json)
          ];
        };
      };
      python = pkgs.python3.withPackages (ps: with ps; [
        requests
        beautifulsoup4
      ]);
      yandex-browser-beta = pkgs.callPackage ./yandex-browser.nix
        (getInfo ./json/yandex-browser-beta.json);
      yandex-browser-stable = pkgs.callPackage ./yandex-browser.nix
        (getInfo ./json/yandex-browser-stable.json);
    in
    {
      nixosModules = {
        yandex-browser = import ./modules/yandex-browser.nix {
          stable = yandex-browser-stable;
          beta = yandex-browser-beta;
        };
      };
      packages.x86_64-linux = {
        yandex-browser-beta = yandex-browser-beta;
        yandex-browser-stable = yandex-browser-stable;
      };
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = [
          python
        ];
      };
      apps.x86_64-linux.update = {
        type = "app";
        program = toString (pkgs.writeScript "update" ''
          #!/usr/bin/env bash
          set -e
          set -x

          ${python}/bin/python3 json/update.py
        '');
      };
    };
}
