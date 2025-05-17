{
  networking = {
    hostName = "nixos";
    enableIPv6 = false;

    networkmanager = {
      enable = true;
      insertNameservers = [ "8.8.8.8" "8.8.4.4" ];
    };

    interfaces.enp42s0 = {
      ipv4.addresses = [{
        address = "192.168.0.200";
        prefixLength = 24;
      }];
    };

    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp42s0";
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 33677 80 8080 443 ];
      allowedUDPPorts = [ 9 ];
    };
  };
}
