# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  fileSystems."/".options = [ "compress-force=zstd" ];

  nixpkgs.config.allowUnfree = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 8;

  networking.hostName = "krypton";

  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp7s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver.displayManager.lightdm = {
    enable = true;
    extraSeatDefaults = "greeter-setup-script=/run/current-system/sw/bin/numlockx";
    greeters.gtk = {
        theme.name = "Arc-Dark";
        cursorTheme.name = "Numix-Cursor-Light";
        theme.package = pkgs.arc-theme;
        cursorTheme.package = pkgs.numix-cursor-theme;
    };
  };

  services.xserver.windowManager.leftwm.enable = true;
  services.xserver.windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  environment.variables = {
      MANPAGER = "sh -c 'col -bx | bat -pl man'";
      VISUAL = "kak";
      EDITOR = "kak";
  };

  environment.homeBinInPath = true;

  environment.shells = [ pkgs.bash pkgs.zsh pkgs.fish pkgs.dash ];

  users.users.abyss = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
  };

  users.users.root = {
    shell = pkgs.fish;
  };

  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
    fontconfig.antialias = true;
    fontconfig.hinting.enable = true;
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      emoji = [ "Noto Color Emoji" "Noto Emoji" ];
      monospace = [ "Monoid" ];
    };
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      monoid
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search <search-name>
  environment.systemPackages = with pkgs; [
    # text editors
    emacs
    neovim
    kakoune

    # shells
    dash
    fish

    # system utilities
    gcc
    git
    curl
    feh
    numlockx
    exa
    ripgrep
    fd
    bat

    # system applications
    slock
    lynx
    dmenu
    xterm
    alacritty
    pavucontrol
    picom

    # user applications
    firefox
    vlc
    vscodium
    libreoffice
    lxappearance

    # etc
    arc-theme
    numix-cursor-theme
  ];

  programs.slock.enable = true;
  programs.fish.enable = true;

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
