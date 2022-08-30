# Yandex Browser for Nix(OS)

With automatic hash updates, I hope.

* `yandex-browser-stable` provides the `yandex-browser` executable
* `yandex-browser-beta` provides the `yandex-browser-beta` executable

## Installation

1. Add to your flake inputs:

   ``` nix
   {
     inputs.nixpkgs.url = "...";
     inputs.yandex-browser.url = "github:Teu5us/nix-yandex-browser";
     inputs.yandex-browser.inputs.nixpkgs.follows = "nixpkgs";
   }
   ```

2. Make sure your inputs are passed to config:

   * Use `specialArgs` for NixOS
   * Use `extraSpecialArgs` for home-manager

3. Import the module you need using `imports` in your config:

   * `inputs.yandex-browser.nixosModule`
   * `inputs.yandex-browser.homeManagerModule`
   
4. Install the browser:

    * Using packages:
    
      ```nix
      {
        # With home-manager
        home.packages = [
          inputs.yandex-browser.packages.yandex-browser-stable
          inputs.yandex-browser.packages.yandex-browser-beta
        ];

        # With configuration.nix
        home.packages = [
          inputs.yandex-browser.packages.yandex-browser-stable
          inputs.yandex-browser.packages.yandex-browser-beta
        ];
      }
      ```

    * Using modules:

      ```nix
      {
        programs.yandex-browser.enable = true;
        # default is "stable", you can also have "both"
        programs.yandex-browser.package = "beta";
      }
      ```
