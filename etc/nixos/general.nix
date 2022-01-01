{ config, pkgs, lib, ... }:

{
  fileSystems."/".options = [ "compress-force=zstd" ];

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

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskell: [ haskell.taffybar ];
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
      mold
      curl
      p7zip
      xclip
      numlockx
      appimage-run

      # cli
      neofetch

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
      taffybar
      firefox
      mpv
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

  programs = {
    fish.enable = true;
    neovim.enable = true;
    slock.enable = true;
    less.enable = true;
    htop.enable = true;
    corectrl.enable = true;
    git.enable = true;
    git.config = {
      init.defaultBranch = "master";
      core = {
        editor = "emacsclient -c -a ''";
        askpass = "";
      };
    };
  };

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
        emoji = [ "Noto Emoji" "Noto Music" ];
        monospace = [ "Hack Nerd Font" "Noto Sans Mono" ];
      };
    };
  };
}
