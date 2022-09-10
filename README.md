# Yandex Browser for Nix(OS)

With automatic hash updates, I hope.

* `yandex-browser-stable` provides the `yandex-browser` executable
* `yandex-browser-beta` provides the `yandex-browser-beta` executable

Try the IPFS backed [web3](https://github.com/teu5us/nix-yandex-browser/tree/web3) branch if you do not plan to track the browser updates.

## Installation

### Command line

1. Using `nix profile`:

   ``` sh
   # Stable version
   nix profile install github:Teu5us/nix-yandex-browser#yandex-browser-stable

   # Beta version
   nix profile install github:Teu5us/nix-yandex-browser#yandex-browser-beta
   ```

2. Temporary shell using `nix shell`:

   ``` sh
   # Stable version
   nix shell github:Teu5us/nix-yandex-browser#yandex-browser-stable

   # Beta version
   nix shell github:Teu5us/nix-yandex-browser#yandex-browser-beta
   ```

### Configuration

1. Add to your flake inputs:

   ``` nix
   {
     inputs.nixpkgs.url = "...";
     inputs.yandex-browser.url = "github:Teu5us/nix-yandex-browser";
     inputs.yandex-browser.inputs.nixpkgs.follows = "nixpkgs";
   }
   ```

   Run `nix flake lock --update-input yandex-browser` before rebuild to get new
   versions and hashes.

2. Make sure your inputs are passed to config:

   * Use `specialArgs` for NixOS
   * Use `extraSpecialArgs` for home-manager

3. Install the browser:

    * Using packages:

      ```nix
      {
        # With home-manager
        home.packages = [
          inputs.yandex-browser.yandex-browser-stable
          inputs.yandex-browser.yandex-browser-beta
        ];

        # With configuration.nix
        home.packages = [
          inputs.yandex-browser.yandex-browser-stable
          inputs.yandex-browser.yandex-browser-beta
        ];
      }
      ```

    * Using modules:

      ```nix
      { config, inputs, ... }: {

        imports = [
           # for NixOS
           inputs.yandex-browser.nixosModule

           # for home-manager
           inputs.yandex-browser.homeManagerModule
        ];

        programs.yandex-browser = {
          enable = true;
          # default is "stable", you can also have "both"
          package = "beta";
          extensions = config.programs.chromium.extensions;

          # NOTE: the following are only for nixosModule
          extensionInstallBlocklist = [
            # disable the "buggy" extension in beta
            "imjepfoebignfgmogbbghpbkbcimgfpd"
          ];
          homepageLocation = "https://ya.ru";
          extraOpts = {
            "HardwareAccelerationModeEnabled" = true;
            "DefaultBrowserSettingEnabled" = false;
            "DeveloperToolsAvailability" = 0;
            "CrashesReporting" = false;
            "StatisticsReporting" = false;
            "DistrStatisticsReporting" = false;
            "UpdateAllowed" = false;
            "ImportExtensions" = false;
            "BackgroundModeEnabled" = false;
            "PasswordManagerEnabled" = false;
            "TranslateEnabled" = false;
            "WordTranslatorDisabled" = true;
            "YandexCloudLanguageDetectEnabled" = false;
            "CloudDocumentsDisabled" = true;
            "DefaultGeolocationSetting" = 1;
            "NtpAdsDisabled" = true;
            "NtpContentDisabled" = true;
          };
        };

      }
      ```

      Make sure to avoid any policies to force install extensions, as those will only prevent extensions from being installed.
