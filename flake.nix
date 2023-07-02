{
  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    utils.url = "github:numtide/flake-utils";

    rust = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "utils";
      };
    };

    dmm = {
      url = "github:abysssol/dmm";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "utils";
        rust.follows = "rust";
      };
    };

    blocklist = {
      url = "https://big.oisd.nl/unbound";
      flake = false;
    };
  };

  outputs = { self, nixos, nixpkgs, rust, dmm, blocklist, ... }:
    let
      lib = nixpkgs.lib;

      system = "x86_64-linux";
      hostname = "tungsten";

      nixpkgsConfig = {
        inherit system;
        # Allow specific unfree packages
        config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "steam"
            "steam-run"
            "steam-original"
            # These are required to enable unfree nvidia drivers
            "nvidia-x11"
            "nvidia-settings"
          ];
      };

      stable = import nixos nixpkgsConfig;
      unstable = import nixpkgs nixpkgsConfig;

      flakePkgs = { inherit rust dmm; };
      defaultPackage = name: value: value.packages.${system}.default;
      flakes = lib.attrsets.mapAttrs defaultPackage flakePkgs;

      specialArgs = {
        inherit system hostname stable unstable flakes blocklist;
      };
    in {
      nixosConfigurations.${hostname} = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hardware-configuration.nix
          ./local-configuration.nix
          ./configuration.nix
        ];
      };
    };
}
