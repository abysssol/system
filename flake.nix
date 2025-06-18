{
  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    rust.url = "github:oxalica/rust-overlay";
    rust.inputs.nixpkgs.follows = "nixpkgs";

    blocklist.url = "github:sjhgvr/oisd";
    blocklist.flake = false;
  };

  outputs =
    {
      nixos,
      nixpkgs,
      rust,
      blocklist,
      ...
    }:
    let
      system = "x86_64-linux";
      hostName = "tungsten";

      nixpkgsConfig = {
        inherit system;
        # Allow specific unfree packages
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixos.lib.getName pkg) [
            # These are required to enable unfree nvidia drivers
            "nvidia-x11"
            "nvidia-settings"

            "steam"
            "steam-run"
            "steam-original"
            "steam-unwrapped"

            "obsidian"
            "unrar"
          ];
      };
      pkgs = import nixos nixpkgsConfig;
      unstable = import nixpkgs nixpkgsConfig;
      inherit (pkgs) lib;

      defaultPackage = name: value: value.packages.${system}.default;
      flakes = lib.mapAttrs defaultPackage { inherit rust; };
    in
    {
      nixosConfigurations.${hostName} = nixos.lib.nixosSystem {
        inherit
          system
          pkgs
          lib
          ;
        specialArgs = {
          inherit
            hostName
            unstable
            flakes
            blocklist
            ;
        };
        modules = [
          ./hardware-configuration.nix
          ./local-configuration.nix
          ./configuration.nix
        ];
      };
    };
}
