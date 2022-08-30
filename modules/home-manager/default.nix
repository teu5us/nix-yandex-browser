packages@{ yandex-browser-stable, yandex-browser-beta }:

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.yandex-browser;
in
{
  options = {
    programs.yandex-browser = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enable Yandex Browser. Adds the selected (`programs.yandex-browser.package`)
          package to `home.packages`.
        '';
      };
      package = mkOption {
        default = "stable";
        type = types.enum [ "stable" "beta" "both" ];
        description = ''
          One of "stable", "beta" or "both".
        '';
      };
    };
  };

  config =
    mkIf cfg.enable {
      home.packages = if cfg.package == "both"
                      then attrValues packages
                      else [ getAttr "yandex-browser-${cfg.package}" packages ];
    };
}
