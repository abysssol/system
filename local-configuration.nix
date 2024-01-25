# Important config, machine-specific
# Look over on new machine

{ pkgs, unstable, flakes, ... }:

{
  # Enable the unfree nvidia gpu drivers if necessary
  #services.xserver.videoDrivers = [ "nvidia" ];

  # Support rocm for amd gpus
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

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

  # Enable networkmanager for wifi support, or disable for ethernet only
  networking.networkmanager.enable = true;

  # Include a blocklist to prevent connecting to ads, spam, malware, etc.
  # Comment out if it imapcts dns resolution performance significantly
  services.unbound.settings = { include = "/etc/unbound/blocklist"; };

  # Change to correct time zone
  time.timeZone = "America/New_York";

  # Change keyboard properties
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  # Create list of desired users
  # Run `mkpasswd` to get a password hash from the desired password
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.fish;

    users = {
      root.hashedPassword =
        "$y$j9T$E416fcyysC9GBYYrcE4B5.$wSuUn9UCRa9czYSmgYDgl3YXjAw024Pq1NbFCYX6zD9";

      abysssol = {
        hashedPassword =
          "$y$j9T$LHtvHpDXZj3cYh8kpVmBi1$6TtarDVDgcW/4tQwTJmaViUqwjw3iVNKb5dVwMtssw9";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "corectrl"
          "openrazer"
          "transmission"
          "libvirtd"
          "kvm"
          "video"
          "render"
          "dialout"
        ];
        packages = with pkgs; [
          (flakes.rust.override {
            targets = [
              "x86_64-unknown-linux-musl"
              "wasm32-unknown-unknown"
              "wasm32-wasi"
            ];
          })
          protontricks
          cargo-show-asm
          unstable.bacon
          ffmpeg-normalize
          mdbook
          razergenie
        ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
