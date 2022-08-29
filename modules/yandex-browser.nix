{ stable, beta }:

{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    programs.yandex-browser = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enable Yandex Browser. Adds the selected (`programs.yandex-browser.package`)
          package to `environment.systemPackages` AND `nixpkgs.config.permittedInsecurePackages`.

          One still needs to configure Nix to allow installation of unfree packages.
        '';
      };
      package = mkOption {
        default = "stable";
        type = types.str;
        description = ''
          One of "stable" or "beta".
        '';
      };
    };
  };

  config = let
    packages = {
      yandex-browser-stable = stable;
      yandex-browser-beta = beta;
    };
    packageType = config.programs.yandex-browser.package;
    package =
      assert (builtins.elem packageType [ "stable" "beta" ]);
      getAttr ("yandex-browser-${packageType}") packages;
  in
    mkIf config.programs.yandex-browser.enable {
      nixpkgs.overlays = [
        (self: super: packages)
      ];
      nixpkgs.config.permittedInsecurePackages = [ package.name ];
      environment.systemPackages = [ package ];
    };
}
