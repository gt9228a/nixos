{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.kernelModules = [ "vfio_pci" "vfio_iommu_type1" "vfio" "kvmfr"];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=1002:67df,1002:aaf0,8086:15b8
    options kvmfr static_size_mb=64
  '';
  
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" "pcie_acs_override=downstream,multifunction" "kvm_intel.nested=1" "kvm.ignore_msrs=1" "kvm_intel.emulate_invalid_guest_state=0" ];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModulePackages = [ pkgs.linuxPackages_zen.kvmfr ];  

  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="michael", GROUP="libvirtd", MODE="0666"
  '';
 

  networking.hostName = "nixos"; 
  networking.networkmanager.enable = true;  

  time.timeZone = "America/New_York";


  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "us";
#  services.xrdp.enable = true;
#  services.xrdp.defaultWindowManager = "startplasma-x11";
#  services.xrdp.openFirewall = true;
#  services.getty.autologinUser = "michael";
#  services.xserver.displayManager.autoLogin.enable = true;
#  services.xserver.displayManager.autoLogin.user = "michael";


  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };


  users.users.michael = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
     ];
   };

   environment.systemPackages = with pkgs; [
     vim 
     git
     wget
     nano
     curl
     swtpm   
   ];

  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [pkgs.OVMFFull.fd];
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    cgroup_device_acl = [
    "/dev/kvmfr0", 
    "/dev/null", "/dev/full", "/dev/zero",
    "/dev/random", "/dev/urandom",
    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
    "/dev/rtc", "/dev/hpet","/dev/net/tun",
    "/dev/vfio/vfio",
        ]
    '';
  
  virtualisation.kvmgt.enable = true;
  virtualisation.kvmgt.vgpus = {
  "i915-GVTg_V5_4" = {
    uuid = [ "dfc6215b-fb46-4755-83b4-7a12175fac5b" ];
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

  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;
  services.tailscale.enable = true;
  
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  system.stateVersion = "24.05"; # Did you read the comment?
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}

