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
      preferencesStatus = "default";
      preferences = {
        "browser.urlbar.shortcuts.tabs" = false;
        "browser.urlbar.suggest.openpage" = false;

        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.download.autohideButton" = true;

        "dom.security.https_only_mode" = true;
        
        # Betterfox
        # "Ad meliora"
        # version: 138
        # url: https://github.com/yokoffing/Betterfox

        # SECTION: FASTFOX
        # GFX
        "gfx.canvas.accelerated.cache-size" = 512;
        "gfx.content.skia-font-cache-size" = 20;

        # DISK
        "browser.cache.disk.enable" = false;

        # MEMORY
        "browser.sessionhistory.max_total_viewers" = 4;

        # MEDIA
        "media.memory_cache_max_size" = 65536;
        "media.cache_readahead_limit" = 7200;
        "media.cache_resume_threshold" = 3600;

        # NETWORK
        "network.http.max-connections" = 1800;
        "network.http.max-persistent-connections-per-server" = 10;
        "network.http.max-urgent-start-excessive-connections-per-host" = 5;
        "network.http.pacing.requests.enabled" = false;
        "network.dnsCacheExpiration" = 3600;
        "network.ssl_tokens_cache_capacity" = 10240;

        # SPECULATIVE
        "network.http.speculative-parallel-limit" = 0;
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.places.speculativeConnect.enabled" = false;
        "network.prefetch-next" = false;
        "network.predictor.enabled" = false;
        "network.predictor.enable-prefetch" = false;

        # EXPERIMENTAL
        "layout.css.grid-template-masonry-value.enabled" = true;

        # SECTION: SECUREFOX
        # TRACKING
        "browser.contentblocking.category" = "strict";
        "browser.download.start_downloads_in_tmp_dir" = true;
        "browser.helperApps.deleteTempFileOnExit" = true;
        "browser.uitour.enabled" = false;
        "privacy.globalprivacycontrol.enabled" = true;

        # OCSP
        "security.OCSP.enabled" = 0;

        # SSL
        "browser.xul.error_pages.expert_bad_cert" = true;
        "security.tls.enable_0rtt_data" = false;

        # DISK
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.sessionstore.interval" = 60000;

        # SEARCH
        "browser.urlbar.trimHttps" = true;
        "browser.urlbar.untrimOnUserInteraction.featureGate" = true;
        "browser.search.separatePrivateDefault.ui.enabled" = true;
        "browser.urlbar.update2.engineAliasRefresh" = true;
        #"browser.search.suggest.enabled" = false;
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.groupLabels.enabled" = false;
        "browser.formfill.enable" = false;
        "network.IDN_show_punycode" = true;

        # PASSWORDS
        "signon.formlessCapture.enabled" = false;
        "signon.privateBrowsingCapture.enabled" = false;
        "network.auth.subresource-http-auth-allow" = 1;

        # MIXED
        "security.mixed_content.block_display_content" = true;
        "pdfjs.enableScripting" = false;

        # EXTENSIONS
        "extensions.enabledScopes" = 5;

        # HEADERS
        "network.http.referer.XOriginTrimmingPolicy" = 2;

        # CONTAINERS
        "privacy.userContext.ui.enabled" = true;

        # SAFE
        "browser.safebrowsing.downloads.remote.enabled" = false;

        # MOZILLA
        "geo.provider.network.url" = "https://beacondb.net/v1/geolocate";
        "browser.search.update" = false;
        "extensions.getAddons.cache.enabled" = false;

        # TELEMETRY
        "datareporting.policy.dataSubmissionEnabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;

        # CRASH
        "browser.tabs.crashReporting.sendReport" = false;

        # SECTION: PESKYFOX
        # MOZILLA
        "browser.privatebrowsing.vpnpromourl" = "";
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.preferences.moreFromMozilla" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.aboutwelcome.enabled" = false;
        "browser.profiles.enabled" = true;

        # THEME
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.compactmode.show" = true;

        # URL
        "browser.urlbar.unitConversion.enabled" = true;
        "browser.urlbar.trending.featureGate" = false;
        "dom.text_fragments.create_text_fragment.enabled" = true;

        # NEW
        "browser.newtabpage.activity-stream.default.sites" = "";
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;

        # POCKET
        "extensions.pocket.enabled" = false;

        # DOWNLOADS
        "browser.download.manager.addToRecentDocs" = false;

        # PDF
        "browser.download.open_pdf_attachments_inline" = true;

        # TAB
        "browser.bookmarks.openInTabClosesMenu" = false;
        "browser.menu.showViewImageInfo" = true;
        "layout.word_select.eat_space_to_next_word" = false;

        # SECTION: SMOOTHFOX
        "general.smoothScroll" = true;
        "general.smoothScroll.msdPhysics.enabled" = true;
      };
      policies = {
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
        };

        SearchEngines = {
          Add = [
            {
              Name = "Wikipedia";
              Alias = "@wikipedia";
              Description = "Crowd sourced encyclopedia";
              IconURL = "https://en.wikipedia.org/favicon.ico";
              URLTemplate = "https://en.wikipedia.org/wiki/{searchTerms}";
              SuggestURLTemplate = "https://en.wikipedia.org/w/index.php?title=Special:Search&search={searchTerms}";
              Method = "GET";
            }
            {
              Name = "Wiktionary";
              Alias = "@wiktionary";
              Description = "Crowd sourced dictionary";
              IconURL = "https://en.wiktionary.org/favicon.ico";
              URLTemplate = "https://en.wiktionary.org/wiki/{searchTerms}";
              SuggestURLTemplate = "https://en.wiktionary.org/w/index.php?title=Special:Search&search={searchTerms}";
              Method = "GET";
            }
            {
              Name = "Merriam-Webster Dictionary";
              Alias = "@dictionary";
              Description = "English dictionary";
              IconURL = "https://merriam-webster.com/favicon.ico";
              URLTemplate = "https://merriam-webster.com/dictionary/{searchTerms}";
              Method = "GET";
            }
            {
              Name = "Power Thesaurus";
              Alias = "@thesaurus";
              Description = "Comprehensive thesaurus";
              IconURL = "https://powerthesaurus.org/favicon.ico";
              URLTemplate = "https://powerthesaurus.org/{searchTerms}";
              Method = "GET";
            }
            {
              Name = "NixOS Options";
              Alias = "@options";
              Description = "Search NixOS options";
              IconURL = "https://nixos.org/favicon.ico";
              URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
              Method = "GET";
            }
            {
              Name = "NixOS Packages";
              Alias = "@packages";
              Description = "Search Nixpkgs";
              IconURL = "https://nixos.org/favicon.ico";
              URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
              Method = "GET";
            }
          ];
        };
      };
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
