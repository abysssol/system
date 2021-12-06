# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  # Allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "nvidia-x11"
    "nvidia-settings"
    "steam"
    "steam-original"
    "steam-runtime"
  ];

  imports = [
    ./hardware-configuration.nix
  ];

  fileSystems."/".options = [ "compress-force=zstd" ];
  fileSystems."/overflow" = {
    device = "/dev/disk/by-uuid/a58c77ad-973f-4243-a882-9a0eab23047f";
    fsType = "btrfs";
    options = [ "compress-force=zstd" ];
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    openrazer.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 8;
    systemd-boot = {
      enable = true;
      editor = false;
      consoleMode = "max";
    };
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

  security.rtkit.enable = true;

  services = {
    transmission.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    xserver = {
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

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskell: [ haskell.taffybar ];
      };

      desktopManager.lxqt.enable = true;
    };
  };

  users.users = {
    root.shell = pkgs.fish;

    abyss = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "transmission" "openrazer" ];
      packages = with pkgs; [
        rustup
        kak-lsp
        rust-analyzer
        mdbook
        godot
        easytag
        multimc
        zola
      ];
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
      GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };
    systemPackages = with pkgs; [
      # text editors
      kakoune
      neovim
      emacs
      vscodium

      # shells
      fish
      dash

      # system
      clang_12
      llvmPackages_latest.bintools
      llvmPackages_latest.lld
      curl
      p7zip
      xclip
      numlockx
      appimage-run

      # cli
      neofetch
      youtube-dl
      pandoc

      exa
      bat
      ripgrep
      fd
      procs
      tokei
      starship

      # gui
      alacritty
      dmenu
      i3lock
      feh
      taffybar
      firefox
      vlc
      kiwix
      libreoffice
      ghostwriter
      audacity
      blender
      krita
      gimp
      inkscape

      # themes
      arc-theme
      paper-icon-theme
      numix-cursor-theme
    ];
  };

  gtk.iconCache.enable = true;

  programs.fish.enable = true;
  programs.slock.enable = true;
  programs.steam.enable = true;
  programs.less.enable = true;
  programs.htop.enable = true;
  programs.git.enable = true;
  programs.git.config = {
    init.defaultBranch = "master";
    core = {
      editor = "kak";
      askpass = "";
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "Hack" ]; })
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Emoji" "Noto Music" ];
        monospace = [ "Hack Nerd Font" "Noto Sans Mono" ];
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
