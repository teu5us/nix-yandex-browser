packages@{ stable, beta }:

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
        type = types.oneOf [ "stable" "beta" ];
        description = ''
          Choose the stable or beta version of the Yandex Browser.
        '';
      };
    };
  };

  config = let
    package = getAttr config.programs.yandex-browser.package packages;
  in
    mkIf config.programs.yandex-browser.enable {
      nixpkgs.config.permittedInsecurePackages = [ package.name ];
      environment.systemPackages = [ package ];
    };
}
