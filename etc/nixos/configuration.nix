# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  # Allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "nvidia-x11"
    "nvidia-settings"
  ];

  imports = [
    ./hardware-configuration.nix
  ];

  fileSystems."/".options = [ "compress-force=zstd" ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.pulseaudio.enable = true;

  sound.enable = true;

  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = false;
      consoleMode = "max";
    };
    efi.canTouchEfiVariables = true;
    timeout = 8;
  };

  time.timeZone = "America/New_York";

  networking = {
    hostName = "krypton";
    useDHCP = false;
    interfaces.enp7s0.useDHCP = true;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    displayManager.lightdm = {
      enable = true;
      extraSeatDefaults = "greeter-setup-script=/run/current-system/sw/bin/numlockx";
      greeters.gtk = {
        extraConfig = "background=/usr/share/backgrounds/nix-background.png";
        theme.name = "Arc-Dark";
        cursorTheme.name = "Numix-Cursor-Light";
        theme.package = pkgs.arc-theme;
        cursorTheme.package = pkgs.numix-cursor-theme;
      };
    };

    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;

    desktopManager.lxqt.enable = true;
  };

  users.users = {
    root.shell = pkgs.fish;

    abyss = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
    };
  };

  environment = {
    homeBinInPath = true;
    shells = [ pkgs.bash pkgs.fish ];
    variables = {
      VISUAL = "kak";
      EDITOR = "kak";
      MANPAGER = "sh -c 'col -bx | bat -pl man'";
      QT_QPA_PLATFORMTHEME = "lxqt";
    };
    systemPackages = with pkgs; [
      # text editors
      neovim
      kakoune
      emacs
      vscodium
  
      # shells
      fish
      dash
  
      # system
      clang_12
      lld_12
      git
      curl
      xclip
      numlockx
  
      exa
      ripgrep
      fd
      bat
  
      # applications
      alacritty
      dmenu
      i3lock
      feh
  
      firefox
      vlc
      libreoffice
      ghostwriter
      qbittorrent
  
      # themes
      arc-theme
      arc-icon-theme
      numix-cursor-theme
    ];
  };

  programs.fish.enable = true;

  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "Monoid" ]; })
    ];
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" "Noto Emoji" ];
        monospace = [ "Monoid Nerd Font Mono" "Noto Sans Mono" ];
      };
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
