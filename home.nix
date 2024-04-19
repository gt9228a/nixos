{ config, pkgs, ... }:

{
  home.username = "michael";
  home.homeDirectory = "/home/michael";


  home.packages = with pkgs; [
    zip
    xz
    unzip
    p7zip
    btop  
    iotop 
    iftop 
    lm_sensors 
    pciutils 
    usbutils       
#    citrix_workspace
    firefox
    google-chrome
    looking-glass-client
    nomachine-client
];

  programs.git = {
    enable = true;
    userName = "gt9228a";
    userEmail = "gt9228a@gmail.com";
    extraConfig = {
     init.defaultBranch = "main";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };


  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
