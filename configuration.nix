# # Documentation is available with the following commands.
# $ man configuration.nix
# $ nixos-help

{
  pkgs,
  hostName,
  unstable,
  blocklist,
  ...
}:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 28d";
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    openrazer.enable = true;
    opentabletdriver.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.timeout = 8;

  networking = {
    inherit hostName;
    nameservers = [
      # use unbound
      "127.0.0.1"
      "::1"
    ];
    dhcpcd.extraConfig = "nohook resolv.conf";
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  security.rtkit.enable = true;

  documentation.dev.enable = true;

  qt.enable = true;
  qt.platformTheme = "lxqt";

  gtk.iconCache.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
    config = {
      common = {
        default = [
          "cosmic"
        ];
      };

      cosmic = {
        default = [
          "cosmic"
        ];
      };
    };
  };

  services = {
    logind.powerKey = "ignore";
    libinput.enable = true;
    openssh.enable = true;
    transmission.enable = true;
    nscd.enableNsncd = true;
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;

    unbound.enable = true;
    unbound.settings = {
      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "1.1.1.1@853#cloudflare-dns.com"
            "1.0.0.1@853#cloudflare-dns.com"
            "8.8.8.8@853#dns.google"
            "8.8.4.4@853#dns.google"
          ];
          forward-tls-upstream = true;
          forward-first = true;
        }
      ];
    };

    pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  environment = {
    homeBinInPath = true;
    localBinInPath = true;
    shells = [ pkgs.fish ];

    etc."unbound/blocklist".source = "${blocklist}/unbound_big.txt";

    systemPackages = with pkgs; [
      # cli
      perl
      strace
      rsync
      rclone
      curl
      dig
      zip
      unzip
      p7zip
      appimage-run
      wasmtime
      xclip
      wl-clipboard
      man-pages
      psmisc
      parallel
      file

      yadm
      neofetch
      yt-dlp
      pandoc
      graphicsmagick
      ffmpeg
      wineWowPackages.full
      monero-cli

      shellharden
      shellcheck
      shfmt
      nil
      nixfmt-rfc-style
      nodePackages.yaml-language-server

      unstable.helix
      tealdeer
      unstable.jujutsu
      eza
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
      trippy
      du-dust
      dysk
      tokei
      starship
      gitui

      # gui
      alacritty
      dmenu
      feh
      keepassxc
      virt-manager
      kid3
      kdePackages.okular
      calibre
      mpv
      vlc
      monero-gui

      firefox
      unstable.tor-browser-bundle-bin
      ungoogled-chromium
      nyxt
      kiwix
      element-desktop

      unstable.prismlauncher

      heroic
      unstable.gogdl
      unstable.legendary-heroic
      unstable.nile

      audacity
      lmms

      godot_4
      blender
      synfigstudio
      inkscape
      mypaint
      krita
      gimp
      darktable

      scribus
      libreoffice
      kdePackages.ghostwriter
      qownnotes
      obsidian
      anki

      obs-studio
      kdePackages.kdenlive
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
    less.enable = true;
    corectrl.enable = true;
    dconf.enable = true;
    ssh.startAgent = true;
    gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

    gnupg.agent.enable = true;
    gnupg.agent.pinentryPackage = pkgs.pinentry-tty;

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
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.hack
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;

      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [
          "Noto Color Emoji"
          "Noto Music"
          "Hack Nerd Font"
        ];
        monospace = [
          "Hack Nerd Font Mono"
          "Noto Sans Mono"
        ];
      };
    };
  };

  systemd.timers.update-blocklist.timerConfig.Persistent = "true";
  systemd.services.update-blocklist = {
    description = "DNS Blocklist Updater";
    serviceConfig.Type = "simple";
    startAt = [ "daily" ];
    after = [ "network.target" ];
    path = with pkgs; [
      curl
      gzip
    ];
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

      while ! curl -sSf "$blocklist_url" >"$blocklist" 2>"$error"; do
        failures=$((failures + 1))
        warning "unable to download blocklist"
        echo "  -| $(cat "$error")" >&2

        if [ "$failures" -gt "$max_failures" ]; then
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
}
