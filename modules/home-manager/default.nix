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

    extensions = mkOption {
      type = types.listOf types.str;
      description = lib.mdDoc ''
        List of chromium extensions to install.
        For list of plugins ids see id in url of extensions on
        [chrome web store](https://chrome.google.com/webstore/category/extensions)
        page. To install a chromium extension not included in the chrome web
        store, append to the extension id a semicolon ";" followed by a URL
        pointing to an Update Manifest XML file. Unlike Chromium, Yandex Browser
        disallows the use of ExtensionInstallForcelist or "force_install"
        in ExtensionSettings, so we override the browser package instead.
        Listed extensions can still be deleted by users, and are not autoinstalled
        afterwards until removed from "external_uninstalls" property in
        $HOME/.config/yandex-browser/Default/Preferences.
      '';
      default = [];
      example = literalExpression ''
        [
          "chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
          "mbniclmhobmnbdlbpiphghaielnnpgdp" # lightshot
          "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
          "kepdippgcikacmcdaijnponnfgljfbea;https://edge.microsoft.com/extensionwebstorebase/v1/crx" # ZenMate VPN from Edge Webstore
        ]
      '';
    };
  };


  config =
    mkIf cfg.enable {
      home.packages =
        let
          withExtensions = p: p.override { extensions = cfg.extensions; };
        in
          if cfg.package == "both"
          then map withExtensions (attrValues packages)
          else
            let
              package = getAttr "yandex-browser-${cfg.package}" packages;
            in [ (withExtensions package) ];
    };
}
