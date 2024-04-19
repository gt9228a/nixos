{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;
#  boot.extraModulePackages = [ pkgs.linuxPackages_zen.kvmfr ];
  boot.kernelModules = [ "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1b06,10de:10ef
    options kvmfr static_size_mb=64
    '';

#   services.udev.extraRules = ''
#   SUBSYSTEM=="kvmfr", OWNER="michael", GROUP="libvirtd", MODE="0666"
# '';

systemd.tmpfiles.rules = [
  "f /dev/shm/looking-glass 0660 michael qemu-libvirtd -"
];

 
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" "pcie_acs_override=downstream,multifunction" "isolcpus=3-5,9-11"]; 

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

  services.displayManager.sddm = {
     enable = true;
     autoNumlock = true;
     wayland.enable= true;   
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "michael";
  services.desktopManager.plasma6.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true; 
    extraPackages = with pkgs; [
        rocmPackages.clr.icd
   ];
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
  virtualisation.libvirtd.qemu.verbatimConfig = ''
     cgroup_device_acl = [
    "/dev/kvmfr0", 
    "/dev/null", "/dev/full", "/dev/zero",
    "/dev/random", "/dev/urandom",
    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
    "/dev/rtc", "/dev/hpet","/dev/net/tun",
    "/dev/vfio/vfio", "/dev/shm/looking-glass"
        ]
'';
  

  services.avahi.enable = true;
  
  environment.etc = {
   "ovmf/edk2-x86_64-secure-code.fd" = {
    source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };
   "ovmf/edk2-i386-vars.fd" = {
    source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

 environment.variables = {
  ROC_ENABLE_PRE_VEGA = "1";
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
];


 virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };


  virtualisation.kvmgt.enable = true;
  virtualisation.kvmgt.vgpus = {
  "i915-GVTg_V5_4" = {
    uuid = [ "dfc6215b-fb46-4755-83b4-7a12175fac5b" ];
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
