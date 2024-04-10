{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  
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
    extraGroups = [ "wheel" "libvirtd" "audio" "input"]; 
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
     vim 
     wget
     nano
     git
     swtpm
     dive
     podman-tui
     podman-compose 
     distrobox
  ];

 virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
   
  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.enable = false;
  services.openssh.settings.X11Forwarding = true;

  system.stateVersion = "24.05"; # Did you read the comment?
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
