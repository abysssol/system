# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ./general.nix ];

  # Allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "steam"
      "steam-original"
      "steam-runtime"
    ];

  fileSystems."/overflow".options = [ "compress-force=zstd" ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    openrazer.enable = true;
    opentabletdriver.enable = true;
  };

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
    interfaces.enp7s0.useDHCP = true;
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    wacom.enable = true;
    digimend.enable = true;

    displayManager = {
      defaultSession = "none+xmonad";
      lightdm.extraSeatDefaults =
        "greeter-setup-script=/run/current-system/sw/bin/numlockx";
      lightdm.greeters.mini = {
        enable = true;
        user = "abyss";
        extraConfig = ''
          [greeter]
          show-password-label = false
          password-alignment = center
          password-input-width = 12
          [greeter-hotkeys]
          mod-key = control
          [greeter-theme]
          background-image = "/etc/nixos/background.png"
          window-color = "#839496"
          border-color = "#268bd2"
          password-border-color = "#268bd2"
        '';
      };
    };
  };

  users.users = {
    abyss = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups =
        [ "wheel" "corectrl" "openrazer" "transmission" "libvirtd" "kvm" ];
      packages = with pkgs; [
        rustup
        rust-analyzer
        mdbook
        multimc
        legendary-gl
        razergenie
        godot
        easytag
      ];
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
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
