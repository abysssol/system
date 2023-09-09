# # Documentation is available with the following commands.
# $ man configuration.nix
# $ nixos-help

{ config, options, lib, hostname, pkgs, stable, unstable, flakes, blocklist, ...
}:

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

  gtk.iconCache.enable = true;

  documentation.dev.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = lib.mkForce [ pkgs.lxqt.xdg-desktop-portal-lxqt ];
  };

  qt.enable = true;
  qt.platformTheme = "lxqt";

  systemd.timers.update-blocklist.timerConfig.Persistent = "true";
  systemd.services.update-blocklist = {
    description = "Dns blocklist updater";
    serviceConfig.Type = "simple";
    startAt = [ "daily" ];
    after = [ "network.target" ];
    path = with pkgs; [ curl gzip ];
    script = ''
      blocklist_url="https://big.oisd.nl/unbound"
      max_failures=20
      failures=0
      blocklist="$(mktemp /tmp/blocklist.XXXXXXX)"
      blocklist_bak="$(mktemp /tmp/blocklist.bak.XXXXXXX)"
      error="$(mktemp /tmp/curl-error.XXXXXXX)"
      info() { echo "info: ""$1"; }
      warning() { echo "warning: ""$1" >&2; }
      error() { echo "error: ""$1" >&2; }
      clean_exit() {
        info "encountered $failures download failures"
        info "exiting"
        rm "$blocklist"
        rm "$blocklist_bak"
        rm "$error"
        exit "$1"
      }

      info "updating blocklist"

      while ! curl -sSf $blocklist_url >"$blocklist" 2>"$error"; do
        failures=$((failures + 1))
        warning "unable to download blocklist"
        echo "  -| $(cat "$error")" >&2

        if [ "$failures" -gt $max_failures ]; then
          warning "reached maximum download failures"
          clean_exit 1
        fi

        sleep $((failures * failures))
      done

      if [ ! -s "$blocklist" ]; then
        error "downloaded blocklist is empty"
        clean_exit 1
      fi

      info "blocklist downloaded successfully"

      cp "/etc/unbound/blocklist" "$blocklist_bak"
      if [ ! -e "/etc/unbound/blocklist.bak" ]; then
        mv "/etc/unbound/blocklist" "/etc/unbound/blocklist.bak"
      fi

      cp "$blocklist" "/etc/unbound/blocklist"
      chmod 644 "/etc/unbound/blocklist"

      info "restarting dns server to activate new blocklist"
      if ! systemctl restart unbound.service; then
        error "dns server failed to restart"

        info "restoring blocklist to previous version"
        cp "$blocklist_bak" "/etc/unbound/blocklist"
        chmod 644 "/etc/unbound/blocklist"

        if systemctl restart unbound.service; then
          info "dns server started correctly with previous blocklist"
          warning "downloaded blocklist was invalid"
          clean_exit 1
        else
          error "dns server failed to start with previous blocklist"
          warning "dns server down"
          clean_exit 2
        fi
      fi

      echo "info: successfully updated blocklist"
      clean_exit 0
    '';
  };

  services = {
    emacs.enable = true;
    openssh.enable = true;
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

    etc."unbound/blocklist".source = blocklist;

    defaultPackages = [ ];
    systemPackages = with pkgs; [
      # cli
      perl
      rsync
      strace
      curl
      dig
      zip
      unzip
      p7zip
      appimage-run
      wasmtime
      numlockx
      xclip
      wl-clipboard
      man-pages
      psmisc

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

      shellcheck
      shfmt
      nil
      nixpkgs-fmt
      nixfmt
      ghc
      haskell-language-server
      nodePackages.yaml-language-server

      flakes.rust
      unstable.rust-analyzer

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

      ungoogled-chromium
      firefox
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
      qownnotes
      libreoffice

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

    firefox = {
      enable = true;
      package = pkgs.librewolf;
      autoConfig = ''
        defaultPref("general.smoothScroll", false);

        defaultPref("browser.startup.homepage", "about:blank");
        defaultPref("browser.newtabpage.enabled", false);

        defaultPref("browser.urlbar.shortcuts.tabs", false);
        defaultPref("browser.urlbar.suggest.openpage", false);

        defaultPref("browser.toolbars.bookmarks.visibility", "always");
        defaultPref("browser.download.autohideButton", true);
      '';
    };

    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = [ ];
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
        emoji = [ "Noto Color Emoji" "Noto Music" "Hack Nerd Font" ];
        monospace = [ "Hack Nerd Font Mono" "Noto Sans Mono" ];
      };
    };
  };
}
