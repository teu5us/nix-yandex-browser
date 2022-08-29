packages@{ yandex-browser-stable, yandex-browser-beta }:

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
          package to `environment.systemPackages`.
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
    packageType = config.programs.yandex-browser.package;
    package =
      assert (builtins.elem packageType [ "stable" "beta" ]);
      getAttr "yandex-browser-${config.programs.yandex-browser.package}" packages;
  in
    mkIf config.programs.yandex-browser.enable {
      environment.systemPackages = [ package ];
    };
}
