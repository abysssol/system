{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    rust = {
      url = "github:oxalica/rust-overlay";
      inputs = { nixpkgs.follows = "nixpkgs-unstable"; };
    };

    dmm = {
      url = "github:abysssol/dmm";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        rust.follows = "rust";
      };
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, rust, dmm, ... }@inputs:
    let
      system = "x86_64-linux";
      hostname = "tungsten";
      flakePkgs = { inherit rust dmm; };

      pkgs = import nixpkgs { inherit system; };
      unstable = import nixpkgs-unstable { inherit system; };

      defaultPackage = name: value: value.packages.${system}.default;
      flakes = pkgs.lib.attrsets.mapAttrs defaultPackage flakePkgs;
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs // { inherit system hostname unstable flakes; };
        modules = [
          ./hardware-configuration.nix
          ./local-configuration.nix
          ./configuration.nix
        ];
      };
    };
}
