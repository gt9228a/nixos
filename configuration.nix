{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules = [ "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1b06,10de:10ef,1002:67df,1002:aaf0
    '';
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" "pcie_acs_override=downstream,multifunction" "isolcpus=3-5,9-11"]; 

  networking.hostName = "nixos"; 
  networking.networkmanager.enable = true;  

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.xserver.enable = true;

  services.displayManager.sddm = {
     enable = true;
     autoNumlock = true;
     wayland.enable= true;   
  };

  #xdg.portal.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "michael";
  services.desktopManager.plasma6.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true; 
 };


  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
   enable = true;
   alsa.enable = true;
   alsa.support32Bit = true;
   pulse.enable = true;
   jack.enable = true; 
   };

  hardware.pulseaudio.enable = false;
  sound.enable = false;

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

  users.users.michael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "audio" "input" "qemu-libvirtd"]; 
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
     nix-index
     clinfo   
     input-leap
];

 virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
 
  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.enable = false;
  services.openssh.settings.X11Forwarding = true;

  system.stateVersion = "24.05"; # Did you read the comment?
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
