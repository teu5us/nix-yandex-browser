{
  description = "Yandex Browser flake for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      python = pkgs.python3.withPackages (ps: with ps; [
        requests
        beautifulsoup4
      ]);
    in
    {
      packages.x86_64-linux =
        let
          getInfo = with builtins; file: fromJSON (readFile file);
        in
        {
          yandex-browser-beta = pkgs.callPackage ./yandex-browser.nix
            (getInfo ./json/yandex-browser-beta.json);
          yandex-browser-stable = pkgs.callPackage ./yandex-browser.nix
            (getInfo ./json/yandex-browser-stable.json);
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
