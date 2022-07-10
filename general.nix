{ config, pkgs, lib, ... }:

{
  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking = {
    useDHCP = false;
    nameservers =
      [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  };

  security.rtkit.enable = true;

  services = {
    emacs.enable = true;
    emacs.package = pkgs.emacsNativeComp;
    transmission.enable = true;
    pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    xserver = {
      enable = true;

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };

      desktopManager.lxqt.enable = true;

      displayManager = {
        lightdm.extraSeatDefaults =
          "greeter-setup-script=/run/current-system/sw/bin/numlockx";
        lightdm.greeters.gtk = {
          enable = true;
          extraConfig = "background=/etc/nixos/background";
          theme.name = "Flat-Remix-GTK-Blue-Darkest";
          theme.package = pkgs.flat-remix-gtk;
          cursorTheme.name = "phinger-cursors";
          cursorTheme.package = pkgs.phinger-cursors;
          cursorTheme.size = 32;
          iconTheme.name = "Paper";
          iconTheme.package = pkgs.paper-icon-theme;
        };
      };
    };
  };

  gtk.iconCache.enable = true;

  users.users.root.shell = pkgs.fish;

  environment = {
    homeBinInPath = true;
    localBinInPath = true;
    shells = [ pkgs.bash pkgs.fish ];
    variables = {
      QT_QPA_PLATFORMTHEME = "lxqt";
      GDK_PIXBUF_MODULE_FILE =
        "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };

    systemPackages = with pkgs; [
      # cli
      llvmPackages_latest.clang
      llvmPackages_latest.bintools
      curl
      xclip
      numlockx
      appimage-run
      alsa-utils

      neofetch
      tldr
      yt-dlp
      pandoc
      imagemagick
      wineWowPackages.full
      p7zip
      wasmer
      ncdu
      yadm

      hunspell
      hunspellDicts.en_US
      shellcheck
      shfmt
      nixfmt
      nodePackages.prettier

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
      feh
      mpv
      vlc
      firefox
      kiwix
      tor-browser-bundle-bin
      virt-manager
      audacity
      blender
      inkscape
      krita
      gimp
      ghostwriter
      libreoffice
      obs-studio
      kdenlive
      godot
      taffybar
      kid3

      # themes
      flat-remix-gtk
      paper-icon-theme
      phinger-cursors
    ];
  };

  programs = {
    fish.enable = true;
    neovim.enable = true;
    slock.enable = true;
    less.enable = true;
    htop.enable = true;
    corectrl.enable = true;
    dconf.enable = true;
    gnupg.agent.enable = true;
    gnupg.agent.pinentryFlavor = "tty";
    git.enable = true;
    git.config = {
      init.defaultBranch = "master";
      core.askpass = "";
      core.editor = "nvim";
    };
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  fonts = {
    enableDefaultFonts = true;
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
        emoji = [ "Noto Color Emoji" "Noto Emoji" "Noto Music" "FontAwesome" ];
        monospace = [ "Hack Nerd Font" "Noto Sans Mono" ];
      };
    };
  };
}
