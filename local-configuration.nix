# Important config, machine-specific
# Look over on new machine

{ config, lib, pkgs, ... }:

let unstable = import <unstable> { };
in {
  # Allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "steam"
      "steam-original"
      "steam-runtime"
    ];

  # Allow insecure package (opentoonz dependency)
  nixpkgs.config.permittedInsecurePackages = [ "libtiff-4.0.3-opentoonz" ];

  # Unfree nvidia gpu drivers (nvidia only)
  services.xserver.videoDrivers = [ "nvidia" ];

  # Compress all files transparently (btrfs only)
  fileSystems."/".options = [ "compress-force=zstd" ];
  # External hard drive
  fileSystems."/ext".options = [ "compress-force=zstd" ];

  # Use systemd-boot as boot loader (uefi systems only, use grub on bios)
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    consoleMode = "max";
  };
  #boot.loader.grub = {
  #  enable = true;
  #  device = "/dev/disk/by-label/boot";
  #};

  networking = {
    # Change to a unique name
    hostName = "krypton";
    # Enable networkmanager for wifi support, or disable for ethernet only
    networkmanager.enable = true;
    # All network interfaces should individually enable dhcp
    interfaces.enp7s0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
  };

  # Only enable ipv6 dns servers if your router and internet service provider support ipv6
  services.dnscrypt-proxy2.settings.ipv6_servers = false;

  # Change to correct time zone
  time.timeZone = "America/New_York";

  # Change keyboard properties
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;
  services.xserver.xkbOptions = "caps:escape";

  # Create list of desired users
  users.users = {
    abyss = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
        "networkmanager"
        "corectrl"
        "openrazer"
        "transmission"
        "libvirtd"
        "kvm"
      ];
      packages = with pkgs; [
        (rust-bin.stable.latest.default.override {
          targets = [ "wasm32-unknown-unknown" "wasm32-wasi" ];
        })
        bacon
        mdbook
        unstable.polychromatic
        unstable.polymc
        unstable.legendary-gl
      ];
    };
  };
}
