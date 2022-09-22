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
    # All network interfaces should individually enable dhcp
    interfaces.enp7s0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
  };

  # Change to correct time zone
  time.timeZone = "America/New_York";

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
        rustup
        bacon
        mdbook
        unstable.polychromatic
        unstable.polymc
        legendary-gl
      ];
    };
  };
}
