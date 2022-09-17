# # Documentation is available with the following commands.
# $ man configuration.nix
# $ nixos-help

{ config, lib, pkgs, ... }:

let unstable = import <unstable> { };
in {
  imports = [ ./local-configuration.nix ./hardware-configuration.nix ];

  hardware = {
    enableRedistributableFirmware = true;
    openrazer.enable = true;
    opentabletdriver.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.timeout = 8;

  security.rtkit.enable = true;

  networking.nameservers =
    [ "1.1.1.1" "2606:4700:4700::1111" "1.0.0.1" "2606:4700:4700::1001" ];
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    insertNameservers =
      [ "1.1.1.1" "2606:4700:4700::1111" "1.0.0.1" "2606:4700:4700::1001" ];
  };

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
      libinput.enable = true;
      wacom.enable = true;
      digimend.enable = true;

      desktopManager.lxqt.enable = true;
      windowManager.xmonad.enable = true;
      windowManager.xmonad.enableContribAndExtras = true;

      displayManager.defaultSession = "none+xmonad";
      displayManager.lightdm.extraSeatDefaults =
        "greeter-setup-script=/run/current-system/sw/bin/numlockx";
      displayManager.lightdm.greeters.gtk = {
        enable = true;
        extraConfig = "background=/etc/nixos/background";
        theme.name = "Flat-Remix-GTK-Blue-Darkest";
        theme.package = pkgs.flat-remix-gtk;
        cursorTheme.name = "phinger-cursors";
        cursorTheme.size = 32;
        cursorTheme.package = pkgs.phinger-cursors;
        iconTheme.name = "Paper";
        iconTheme.package = pkgs.paper-icon-theme;
      };
    };
  };

  environment = {
    homeBinInPath = true;
    localBinInPath = true;
    shells = with pkgs; [ bash zsh fish elvish ];

    variables = {
      QT_QPA_PLATFORMTHEME = "lxqt";
      GDK_PIXBUF_MODULE_FILE =
        "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };

    systemPackages = with pkgs; [
      # cli
      curl
      numlockx
      xclip
      xdotool
      xorg.xprop
      usbutils
      lshw
      alsa-utils
      appimage-run
      p7zip

      yadm
      tldr
      neofetch
      yt-dlp
      pandoc
      graphicsmagick
      wineWowPackages.full
      wasmtime

      llvmPackages_latest.clang
      llvmPackages_latest.bintools
      llvmPackages_latest.llvm
      llvmPackages_latest.lldb

      unstable.rustc
      unstable.cargo
      unstable.clippy
      unstable.rust-analyzer
      unstable.rustfmt

      ghc
      haskell-language-server
      haskellPackages.brittany

      hunspell
      hunspellDicts.en_US
      shellcheck
      shfmt
      nixfmt
      nodePackages.prettier
      nodePackages.yaml-language-server

      unstable.helix
      exa
      zoxide
      broot
      bat
      hexyl
      ripgrep
      fd
      choose
      sd
      procs
      zenith
      du-dust
      lfs
      tokei
      starship

      # gui
      alacritty
      dmenu
      taffybar
      feh
      mpv
      vlc
      firefox
      unstable.tor-browser-bundle-bin
      unstable.kiwix
      virt-manager

      audacity
      lmms
      ardour

      unstable.synfigstudio
      opentoonz
      blender

      inkscape
      mypaint
      krita
      gimp

      scribus
      ghostwriter
      libreoffice
      vscodium

      obs-studio
      kdenlive
      flowblade
      godot
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
    nm-applet.enable = true;
    corectrl.enable = true;
    dconf.enable = true;
    gnupg.agent.enable = true;
    gnupg.agent.pinentryFlavor = "tty";

    git.enable = true;
    git.config = {
      init.defaultBranch = "master";
      core.askpass = "";
      core.editor = "hx";
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  users.users.root.shell = pkgs.fish;

  gtk.iconCache.enable = true;

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
