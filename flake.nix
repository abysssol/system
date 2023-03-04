{
  inputs = {
    nixos.url = "github:nixos/nixpkgs/release-22.11";
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
  };

  outputs = { self, nixos, nixpkgs, rust, dmm, ... }:
    let
      system = "x86_64-linux";
      hostname = "tungsten";

      flakePkgs = { inherit rust dmm; };
      nixpkgsConfig = { inherit system; };

      pkgs = import nixos nixpkgsConfig;
      unstable = import nixpkgs nixpkgsConfig;

      defaultPackage = name: value: value.packages.${system}.default;
      flakes = pkgs.lib.attrsets.mapAttrs defaultPackage flakePkgs;

      specialArgs = { inherit system hostname unstable flakes; };
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
