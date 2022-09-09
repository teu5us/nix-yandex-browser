{ config, lib, ... }:

with lib;

let
  cfg = config.programs.yandex-browser;

  idToSetting = id:
    { name = id; value = { "installation_mode" = "force_installed"; }; };

  defaultProfile = filterAttrs (k: v: v != null) {
    HomepageLocation = cfg.homepageLocation;
    DefaultSearchProviderEnabled = cfg.defaultSearchProviderEnabled;
    DefaultSearchProviderSearchURL = cfg.defaultSearchProviderSearchURL;
    DefaultSearchProviderSuggestURL = cfg.defaultSearchProviderSuggestURL;
    ExtensionSettings = {
      "*" = {
        "installation_mode" = if cfg.blockExtensions == true
                              then "allowed"
                              else "blocked";
      };
    } // lib.listToAttrs (map idToSetting cfg.extensions);
    # ExtensionInstallForcelist = cfg.extensions;
  };
in

{
  ###### interface

  options = {
    programs.yandex-browser = {
      enable = mkEnableOption "<command>yandex-browser</command> policies";

      blockExtensions = mkOption {
        type = types.bool;
        description = lib.mkDoc ''
          Whether unlisted extensions should be blocked.
        '';
        default = false;
        example = literalExpression ''
          true
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
          pointing to an Update Manifest XML file. See
          [ExtensionInstallForcelist](https://cloud.google.com/docs/chrome-enterprise/policies/?policy=ExtensionInstallForcelist)
          for additional details.
        '';
        default = [];
        example = literalExpression ''
          [
            "chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
            "mbniclmhobmnbdlbpiphghaielnnpgdp" # lightshot
            "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
            "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
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
    environment.etc."opt/yandex/browser/policies/managed/managed_policies.json".text =
        builtins.toJSON (cfg.extraOpts // defaultProfile);
  };
}
