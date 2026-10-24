# libvirt_vm

Creates KVM guests from the Debian cloud image with cloud-init. Hypervisor only: it does not configure the guest OS (run the other roles and MASH on the guest through the inventory).

- Guests are the hosts of the `vms` group with `vm_hypervisor` set to this host; each describes itself in its `host_vars` (`vm_ip`, `vm_user`, `vm_network`, `vm_vcpus`, `vm_memory_mib`, `vm_disk_gib`, `vm_shares`, `vm_hostdevs`). `--extra-vars libvirt_vm_only=<host>` limits the run to one guest. Authorized keys come from `libvirt_vm_ssh_authorized_keys` on the hypervisor.
- Isolated libvirt networks (`libvirt_vm_networks`, forward mode `open`: libvirt adds no firewall rules). Give each VM its own network if VMs must not reach each other. `/etc/nftables.d/50-libvirt-vm.nft` NATs the guests to the Internet, blocks `libvirt_vm_blocked_destinations`, any IPv6, and anything from the guests to the host.
- `math-libvirt-vm-docker-user.service` lets Docker's `FORWARD` policy pass the bridge via `DOCKER-USER`. Disable with `libvirt_vm_docker_user_rules: false` if Docker is absent.
- Guest user has passwordless sudo and only key authentication.
- `vm_shares` are virtiofs (`source` host dir, `tag` mount tag); mount them in the guest with `fstab_mounts` (`fstype: virtiofs`, `src: <tag>`).
- `vm_hostdevs` pass PCI devices through (for example the Intel iGPU `0000:00:02.0`). Needs the IOMMU enabled on the kernel command line, and the host loses the device. Intel iGPUs often need extra work (OVMF, legacy mode); test it before depending on it.

The network and domain definitions are applied once. Editing them later means `virsh` or removing the old definition. The disk is copied from the image once and never recreated.

Manual-only role (not in `bootstrap`); enabled for hosts in the `vm_hosts` group. Tag `create-vms` runs `nftables_firewall` then this role (`just math-create-vms [vm]`).
