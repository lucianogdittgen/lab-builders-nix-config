{ inputs, lib, ... }:

{
  imports =
    with inputs.nixos-hardware.nixosModules;
    [
      common-cpu-intel
      common-pc-ssd
    ]
    ++ [
      ../features/required
      ../features/shared-state-yocto
      ../features/zram-swap.nix
      ./partitioning.nix
    ];

  # Keep upstream automatic upgrades from replacing this host's local configuration.
  system.autoUpgrade.enable = lib.mkForce false;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
      ];
    };
    kernelModules = [ "kvm-intel" ];
  };
}
