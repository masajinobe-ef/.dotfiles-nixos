{ ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 2;
    };

    kernelParams = [
      "loglevel=4"
      "mitigations=off"
      "nmi_watchdog=0"
      "amd_pstate=active"
      "cpufreq.default_governor=performance"
    ];
  };
}
