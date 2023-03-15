# # Documentation is available with the following commands.
# $ man configuration.nix
# $ nixos-help

{ config, options, lib, hostname, pkgs, stable, unstable, flakes, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.pkgs = stable;

  hardware = {
    enableRedistributableFirmware = true;
    openrazer.enable = true;
    opentabletdriver.enable = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.timeout = 8;

  networking = {
    hostName = hostname;
    nameservers = [ "127.0.0.1" "::1" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  security.rtkit.enable = true;
  users.users.root.shell = pkgs.fish;
  gtk.iconCache.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    lxqt.enable = true;
  };

  qt5.enable = true;
  qt5.platformTheme = "lxqt";

  systemd.timers.update-blocklist.timerConfig.Persistent = "true";
  systemd.services.update-blocklist = {
    description = "Dns blocklist updater";
    serviceConfig.Type = "simple";
    startAt = [ "daily" ];
    after = [ "network.target" ];
    path = with pkgs; [ curl sd gzip ];
    script = ''
      echo "info: beginning blocklist update"

      tmp_blocklist="$(mktemp /tmp/oisd-blocklist.XXXXXX)"
      tmp_error="$(mktemp /tmp/curl-error.XXXXXX)"
      failures=0

      while ! curl -sSf "https://unbound.oisd.nl/" >"$tmp_blocklist" 2>"$tmp_error"; do
        failures=$((failures + 1))

        if [ "$failures" -gt 60 ]; then
          rm $tmp_blocklist
          echo "error: unable to download blocklist for one hour" >&2
          echo "  -| $(cat "$tmp_error")" >&2
          echo "debug: stopped after $failures download failures"
          exit 1
        fi

        sleep 1m
      done

      if [ ! -s "$tmp_blocklist" ]; then
        rm $tmp_blocklist
        echo "error: downloaded blocklist is empty" >&2
        echo "debug: stopped with $failures download failures"
        exit 1
      fi

      sd "^\*\." "" "$tmp_blocklist"
      mkdir -p "/etc/nixos/blocklist-history/"
      gzip -9c "$tmp_blocklist" >"/etc/nixos/blocklist-history/blocklist.$(date +%F.%T).gz"
      cp "$tmp_blocklist" "/etc/nixos/blocklist"
      chmod 644 "/etc/nixos/blocklist"
      rm $tmp_blocklist

      echo "info: successfully updated blocklist"
      echo "debug: finished with $failures download failures"
    '';
  };

  services = {
    emacs.enable = true;
    transmission.enable = true;
    nscd.enableNsncd = true;
    unbound.enable = true;
    unbound.settings = {
      forward-zone = [{
        name = ".";
        forward-addr =
          [ "1.1.1.1@853#cloudflare-dns.com" "1.0.0.1@853#cloudflare-dns.com" ];
        forward-tls-upstream = true;
        forward-first = true;
      }];
    };

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
      gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

      desktopManager.lxqt.enable = true;

      windowManager.xmonad.enable = true;
      windowManager.xmonad.enableContribAndExtras = true;

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
    shells = [ pkgs.fish ];

    defaultPackages = [ ];
    systemPackages = with pkgs; [
      # cli
      nano
      perl
      rsync
      strace
      curl
      zip
      unzip
      p7zip
      appimage-run
      wasmtime
      numlockx
      xclip
      wl-clipboard

      yadm
      tldr
      neofetch
      yt-dlp
      pandoc
      graphicsmagick
      wineWowPackages.full
      haskellPackages.status-notifier-item
      unstable.gogdl
      unstable.legendary-gl

      llvmPackages_latest.clang
      llvmPackages_latest.bintools
      llvmPackages_latest.lldb

      unstable.rust-analyzer
      flakes.rust

      shellcheck
      shfmt
      nil
      nixpkgs-fmt
      ghc
      haskell-language-server
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
      mprocs
      procs
      zenith
      du-dust
      lfs
      tokei
      starship
      zellij
      gitui
      flakes.dmm

      # gui
      alacritty
      dmenu
      feh
      virt-manager
      taffybar
      kid3
      swaylock

      mpv
      vlc

      firefox
      librewolf
      unstable.tor-browser-bundle-bin
      kiwix

      unstable.prismlauncher
      unstable.heroic

      audacity
      lmms

      godot
      blender
      synfigstudio
      inkscape
      mypaint
      krita
      gimp
      darktable

      scribus
      ghostwriter
      libreoffice
      vscodium

      obs-studio
      kdenlive
      flowblade

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

    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = [];
    };

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
