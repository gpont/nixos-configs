{ pkgs, lib, name ? "nixvm", memory ? 6144, cores ? 2, diskSize ? "20G", sharedPaths ? [ "." ] }:
let
  vmTmp = "../.vm-tmp";
  diskPath = "${vmTmp}/${name}.qcow2";
  isoPath = "${vmTmp}/nixos.iso";
  mk9pArgs = path: [
    "-fsdev local,id=src,path=${path},security_model=none"
    "-device virtio-9p-pci,fsdev=src,mount_tag=src"
  ];
  sharedArgs = lib.concatStringsSep " " (lib.flatten (map mk9pArgs sharedPaths));
  runNixVMScript = pkgs.writeShellScriptBin "run-${name}" ''
    set -euo pipefail
    mkdir -p ${vmTmp}
    if [ ! -f "${diskPath}" ]; then
      ${pkgs.qemu}/bin/qemu-img create -f qcow2 "${diskPath}" "${diskSize}"
    fi
    if [ ! -f "${isoPath}" ]; then
      ${pkgs.curl}/bin/curl -L "https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso" -o "${isoPath}"
    fi
    exec ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -m ${toString memory} \
      -smp ${toString cores} \
      -drive file=${diskPath},if=virtio,format=qcow2 \
      -cdrom ${isoPath} \
      -net nic,model=virtio \
      -net user,dns=8.8.8.8 \
      -boot order=d \
      -nographic \
      -serial mon:stdio \
      -monitor unix:${vmTmp}/qemu-monitor.sock,server,nowait \
      ${sharedArgs} \
      "$@"
  '';
  runNixVMDiskScript = pkgs.writeShellScriptBin "run-${name}-disk" ''
    set -euo pipefail
    exec ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -m ${toString memory} \
      -smp ${toString cores} \
      -drive file=${diskPath},if=virtio,format=qcow2 \
      -net nic,model=virtio \
      -net user,dns=8.8.8.8 \
      -boot order=c \
      -nographic \
      -serial mon:stdio \
      -monitor unix:${vmTmp}/qemu-monitor.sock,server,nowait \
      ${sharedArgs} \
      "$@"
  '';
in {
  runNixVMScript = runNixVMScript;
  runNixVMDiskScript = runNixVMDiskScript;
} 