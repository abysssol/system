{ config, pkgs, lib, ... }:

{
  hardware = { enableRedistributableFirmware = true; };

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
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    xserver = {
      enable = true;

      windowManager.leftwm.enable = true;

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };

      desktopManager.lxqt.enable = true;
    };
  };

  users.users.root.shell = pkgs.fish;

  environment = {
    homeBinInPath = true;
    shells = [ pkgs.bash pkgs.fish ];
    variables = {
      VISUAL = "emacsclient -c -a ''";
      EDITOR = "emacsclient -c -a ''";
      MANPAGER = "sh -c 'col -bx | bat -pl man'";
      QT_QPA_PLATFORMTHEME = "lxqt";
      GDK_PIXBUF_MODULE_FILE =
        "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };
    systemPackages = with pkgs; [
      # system
      clang_12
      llvmPackages_latest.bintools
      curl
      tldr
      xclip
      numlockx
      appimage-run
      alsa-utils

      # cli
      yt-dlp
      pandoc
      imagemagick
      neofetch
      wineWowPackages.full
      ncdu
      p7zip
      wasmer
      rlwrap
      shellcheck
      shfmt
      nixfmt
      nodePackages.prettier
      haskellPackages.brittany

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
      libreoffice
      ghostwriter
      audacity
      blender
      krita
      gimp
      inkscape
      obs-studio
      kdenlive
      easytag
      godot
      taffybar

      # themes
      numix-solarized-gtk-theme
      paper-icon-theme
      nordzy-cursor-theme
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
    git.enable = true;
    git.config = {
      init.defaultBranch = "master";
      core = {
        editor = "emacsclient -c -a ''";
        askpass = "";
      };
    };
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  gtk.iconCache.enable = true;

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
