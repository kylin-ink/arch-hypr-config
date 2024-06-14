{ 
  pkgs,
  ...
}: {
  programs.aria2 = {
    enable = true;
    # TODO get bt-tracker from https://github.com/ngosang/trackerslist, maybe write a script later.
    extraConfig = ''
      bt-tracker=http://93.158.213.92:1337/announce,udp://89.234.156.205:451/announce,udp://185.243.218.213:80/announce,udp://23.153.248.83:6969/announce,udp://167.99.185.219:6969/announce,udp://208.83.20.20:6969/announce,udp://135.125.202.143:6969/announce,udp://176.56.6.248:6969/announce,udp://176.31.250.174:6969/announce,udp://83.102.180.21:80/announce,udp://37.235.176.37:2710/announce,udp://45.9.60.30:6969/announce,udp://37.27.4.53:6969/announce,udp://94.243.222.100:6969/announce,udp://185.216.179.62:25/announce,udp://23.157.120.14:6969/announce
    '';
    settings = {
      listen-port = 4001;
      dht-listen-port = 4000;
      enable-rpc = true;
      rpc-listen-all = true;
      rpc-allow-origin-all = true;
    };
  };
  home.packages = with pkgs; [
    ariang
  ];
}
