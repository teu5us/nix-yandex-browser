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
          package to `environment.systemPackages`.
        '';
      };
      package = mkOption {
        default = "stable";
        type = types.str;
        description = ''
          One of "stable", "beta" or "both".
        '';
      };
    };
  };

  config = let
    package =
      assert (builtins.elem cfg.package [ "stable" "beta" "both" ]);
      if cfg.package == "both"
        then attrValues packages
        else getAttr "yandex-browser-${cfg.package}" packages;
  in
    mkIf cfg.enable {
      environment.systemPackages = if cfg.package == "both" then package else [ package ];
    };
}
