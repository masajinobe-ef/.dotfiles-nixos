{ ... }:

{
  users.users.masa = {
    isNormalUser = true;
    description = "masa";
    extraGroups =
      [ "networkmanager" "wheel" "seat" "audio" "realtime" "input" ];
  };
}
