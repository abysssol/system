# Important config, machine-specific
# Look over on new machine

{ config, lib, pkgs, ... }:

let unstable = import <unstable> { };
in
{
  # Allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-run"
      "steam-original"

      # If unfree nvidia drivers are enabled, these are required
      #"nvidia-x11"
      #"nvidia-settings"
    ];

  # Enable the unfree nvidia gpu drivers if necessary
  #services.xserver.videoDrivers = [ "nvidia" ];

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

  # Include a blocklist to prevent connecting to ads, spam, malware, etc.
  # Comment out if it imapcts dns resolution performance significantly
  services.unbound.settings = {
    include = "/etc/nixos/blocklist";
  };

  # Change to correct time zone
  time.timeZone = "America/New_York";

  # Change keyboard properties
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;
  services.xserver.xkbOptions = "caps:escape";

  # Light control integration for motherboards. Either "amd" or "intel".
  services.hardware.openrgb.motherboard = "amd";

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
        razergenie
        unstable.prismlauncher
        unstable.heroic
        unstable.gogdl
        unstable.legendary-gl
      ];
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
