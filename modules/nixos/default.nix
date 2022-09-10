packages@{ yandex-browser-stable, yandex-browser-beta }:

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.yandex-browser;

  defaultProfile = filterAttrs (k: v: v != null) {
    HomepageLocation = cfg.homepageLocation;
    DefaultSearchProviderEnabled = cfg.defaultSearchProviderEnabled;
    DefaultSearchProviderSearchURL = cfg.defaultSearchProviderSearchURL;
    DefaultSearchProviderSuggestURL = cfg.defaultSearchProviderSuggestURL;
    ExtensionInstallAllowlist = cfg.extensions ++ cfg.extensionInstallAllowlist;
    ExtensionInstallBlocklist = cfg.extensionInstallBlocklist;
  };
in

{
  ###### interface

  options = {
    programs.yandex-browser = {
      enable = mkEnableOption "<command>yandex-browser</command> policies";

      package = mkOption {
        default = "stable";
        type = types.enum [ "stable" "beta" "both" ];
        description = ''
          One of "stable", "beta" or "both".
        '';
      };

      extensionInstallBlocklist = mkOption {
        type = types.listOf types.str;
        description = lib.mkDoc ''
          Extension IDs to be blocklisted.
        '';
        default = [];
        example = literalExpression ''
          [ "*" ]
        '';
      };

      extensionInstallAllowlist = mkOption {
        type = types.listOf types.str;
        description = lib.mkDoc ''
          Extensions IDs not subject to the blocklist.
        '';
        default = [];
        example = literalExpression ''
          [ "*" ]
        '';
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

      homepageLocation = mkOption {
        type = types.nullOr types.str;
        description = lib.mdDoc "Chromium default homepage";
        default = null;
        example = "https://nixos.org";
      };

      defaultSearchProviderEnabled = mkOption {
        type = types.nullOr types.bool;
        description = lib.mdDoc "Enable the default search provider.";
        default = null;
        example = true;
      };

      defaultSearchProviderSearchURL = mkOption {
        type = types.nullOr types.str;
        description = lib.mdDoc "Chromium default search provider url.";
        default = null;
        example =
          "https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
      };

      defaultSearchProviderSuggestURL = mkOption {
        type = types.nullOr types.str;
        description = lib.mdDoc "Chromium default search provider url for suggestions.";
        default = null;
        example =
          "https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}";
      };

      extraOpts = mkOption {
        type = types.attrs;
        description = ''
          Extra chromium policy options. A list of available policies
          can be found in the Chrome Enterprise documentation:
          <link xlink:href="https://cloud.google.com/docs/chrome-enterprise/policies/">https://cloud.google.com/docs/chrome-enterprise/policies/</link>
          Make sure the selected policy is supported on Linux and your browser version.
        '';
        default = {};
        example = literalExpression ''
          {
            "BrowserSignin" = 0;
            "SyncDisabled" = true;
            "PasswordManagerEnabled" = false;
            "SpellcheckEnabled" = true;
            "SpellcheckLanguage" = [
                                     "de"
                                     "en-US"
                                   ];
          }
        '';
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      let
        withExtensions = p: p.override { extensions = cfg.extensions; };
      in
        if cfg.package == "both"
        then map withExtensions (attrValues packages)
        else
          let
            package = getAttr "yandex-browser-${cfg.package}" packages;
          in [ (withExtensions package) ];

    environment.etc."opt/yandex/browser/policies/managed/managed_policies.json".text =
        builtins.toJSON (cfg.extraOpts // defaultProfile);
  };
}
