{
  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    utils.url = "github:numtide/flake-utils";

    blocklist.url = "github:sjhgvr/oisd";
    blocklist.flake = false;

    rust = {
      url = "github:oxalica/rust-overlay/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dmm = {
      url = "github:abysssol/dmm";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "utils";
        rust.follows = "rust";
      };
    };
  };

  outputs = { nixos, nixpkgs, rust, dmm, blocklist, ... }:
    let
      system = "x86_64-linux";
      hostname = "tungsten";

      nixpkgsConfig = {
        inherit system;
        # Allow specific unfree packages
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixos.lib.getName pkg) [
            # These are required to enable unfree nvidia drivers
            "nvidia-x11"
            "nvidia-settings"

            "steam"
            "steam-run"
            "steam-original"
          ];
      };
      pkgs = import nixos nixpkgsConfig;
      unstable = import nixpkgs nixpkgsConfig;
      inherit (pkgs) lib;

      defaultPackage = name: value: value.packages.${system}.default;
      flakes = lib.mapAttrs defaultPackage {
        inherit rust dmm;
      };
      specialArgs = { inherit hostname unstable flakes blocklist; };
    in
    {
      nixosConfigurations.${hostname} = nixos.lib.nixosSystem {
        inherit system pkgs lib specialArgs;
        modules = [
          ./hardware-configuration.nix
          ./local-configuration.nix
          ./configuration.nix
        ];
      };
    };
}
