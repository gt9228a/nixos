{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [ {
    name = "add-acs-overrides";
    patch = ./acs-overrides.patch;
  } ];
  
  boot.kernelModules = [ "vfio_pci" "vfio_iommu_type1" "vfio"];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=1002:67df,1002:aaf0,8086:15b8
    '';

  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" "pcie_acs_override=downstream,multifunction" "isolcpus=2-5,8-11"];

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
 
  hardware.nvidia = {
     modesetting.enable = true;
     powerManagement.enable = false;
     powerManagement.finegrained = false;
     open = false;
     nvidiaSettings = true;
    };


  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [pkgs.OVMFFull.fd];  
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  systemd.user.services.sunshine = {
      description = "Sunshine self-hosted game stream host for Moonlight";
      startLimitBurst = 5;
      startLimitIntervalSec = 500;
      serviceConfig = {
        ExecStart = "${config.security.wrapperDir}/sunshine";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  
  environment.etc = {
   "ovmf/edk2-x86_64-secure-code.fd" = {
    source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };
   "ovmf/edk2-i386-vars.fd" = {
    source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  virtualisation.kvmgt.enable = true;
  virtualisation.kvmgt.vgpus = {
  "i915-GVTg_V5_4" = {
    uuid = [ "dfc6215b-fb46-4755-83b4-7a12175fac5b" ];
    };
  };

  users.users.michael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirt" "audio" "input"]; 
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
     vim 
     wget
     nano
     git
     swtpm
#     sunshine
     dive
     podman-tui
     podman-compose 
     distrobox
  ];

#security.wrappers.sunshine = {
#      owner = "root";
#      group = "root";
#      capabilities = "cap_sys_admin+p";
#      source = "${pkgs.sunshine}/bin/sunshine";
#  };

 virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

services.xrdp.enable = true;
services.xrdp.defaultWindowManager = "startplasma-x11";
services.xrdp.openFirewall = true;

#security.acme.acceptTerms = true;
#security.acme.defaults.email = "michael@romilimi.com";
#security.acme.certs."romilimi.com" = {
#  domain = "*.romilimi.com";
#  dnsProvider = "rfc2136";
#  environmentFile = "/var/lib/secrets/certs.secret";
#  dnsPropagationCheck = true;
#};

  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
   
  security.polkit.enable = true;
  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.enable = false;
  services.openssh.settings.X11Forwarding = true;

  system.stateVersion = "24.05"; # Did you read the comment?
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
