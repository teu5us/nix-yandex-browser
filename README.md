# Yandex Browser for Nix(OS)

With automatic hash updates, I hope.

* `yandex-browser-stable` provides the `yandex-browser` executable
* `yandex-browser-beta` provides the `yandex-browser-beta` executable

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

      Import the module you need using `imports` in your config:

        * `inputs.yandex-browser.nixosModule`
        * `inputs.yandex-browser.homeManagerModule`

      ```nix
      {
        programs.yandex-browser.enable = true;
        # default is "stable", you can also have "both"
        programs.yandex-browser.package = "beta";
      }
      ```
