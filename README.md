# math-playbook

Ansible roles for the parts of a Debian-family server that [MASH](https://github.com/mother-of-all-self-hosting/mash-playbook) does not manage: base host setup, mail relay, APT upgrades, a host firewall and KVM virtual machines. It is meant to run next to MASH on the same hosts and share its inventory, but it works on its own. Maintained by [The Immutable Zero (sudo-Tiz)](https://github.com/sudo-Tiz).

Each role does one thing, is idempotent, and can be rerun. All roles target Debian-family hosts and are tagged `role-<name>`; those meant for a first setup also carry the `bootstrap` tag.

## Roles

| Role | What it does | Bootstrap |
|------|--------------|-----------|
| `dns_resolver` | Regular `resolv.conf` or systemd-resolved drop-in, Quad9 by default | yes |
| `fast_linux_config` | Neovim, tmux, Zsh, Git and the dotfiles for the selected users | yes |
| `fstab_mounts` | `/etc/fstab` entries (ext4, virtiofs…) mounted immediately | yes |
| `system_timezone` | Host timezone | yes |
| `msmtp_relay` | `sendmail` through MASH's Exim relay on `127.0.0.1:25` | yes |
| `apt_upgrade_helpers` | `apt-listchanges`, `needrestart`, `apt-listbugs` (Debian) | yes |
| `unattended_upgrades` | Automatic security upgrades, no automatic reboot | yes |
| `apt_full_upgrade` | APT full-upgrade on demand, optional reboot if required | no |
| `reboot_server` | Reboot and wait for the host | no |
| `nftables_firewall` | Default-drop input firewall in its own nftables table | no |
| `libvirt_vm` | KVM guests from the Debian cloud image, with an isolated NAT network | no |

Each role has its own README under `roles/<name>/`.

## Usage

Run from the parent repository (`server/`), which syncs the shared inventory before every run:

- `just math-bootstrap [host]` — apply the bootstrap roles. `host` is a host or group, `math_servers` by default.
- `just math-full-upgrade [host]` — upgrade packages within the current OS release; APT may remove packages. It does not upgrade the Debian/Ubuntu release.
- `just math-reboot` — explicitly reboot the server and wait for it to return.
- `just math-create-vms [vm]` — host firewall then VMs (tag `create-vms`: `nftables_firewall` + `libvirt_vm`); `vm` limits it to one guest.
- `just math-run-tags role-dns_resolver` — apply one role; `just math-run-tags <tag>` runs any role or task tag.
- `just math-run-tags role-nftables_firewall` — host input firewall for `firewall_hosts` (keep a second SSH session open).
- `just math-run-tags role-libvirt_vm` — create the VMs of `vm_hosts`.
- `just math-list-tags` — list the available tags.

`apt_full_upgrade`, `reboot_server`, `nftables_firewall` and `libvirt_vm` are deliberately excluded from `math-bootstrap`: they need an explicit command.

Requires the Ansible community package (not only `ansible-core`): the roles use `ansible.posix`, `community.general` and `community.libvirt`.

## Inventory

Use the shared `server/inventory` source; the root `justfile` copies it to `math-playbook/inventory/` before each run (git-ignored). Math-specific host values go in `inventory/host_vars/<host>/vars.yml`; set `system_mail_recipient` there to receive changelog mail. Shared `group_vars` are versioned in `server/inventory/group_vars`. `examples/` holds a sanitized `hosts` and `host_vars` for a host and a VM.

The play structure in `setup.yml`:

1. `math_servers` — the bootstrap roles above, plus the on-demand upgrade and reboot roles.
2. `firewall_hosts` — `nftables_firewall`.
3. `vm_hosts` — `libvirt_vm`.

### Defaults from `group_vars/math_servers`

- `fast_linux_config_version` is `main` (follow the dotfiles branch). The role itself defaults to commit `d3aef251e1d1d5ad5078e273d17a03f870001ebf`; to pin a host, set it in its `host_vars`.
- `fast_linux_config_users` is the SSH user and `root`.
- `msmtp_relay_from` is `<host>@<mail_domain>` (`mail_domain` comes from `group_vars/base`), `msmtp_relay_host/port` follow `mail_relay_host/port`.

Override any of them in `host_vars` when needed. The dotfiles role sets the selected users' login shell to Zsh; existing dotfiles are backed up when replaced.

## Virtual machines

A VM is a host of the `vms` group. It describes itself in its own `host_vars` (`vm_hypervisor`, `vm_user`, `vm_network`, `vm_ip`, `vm_vcpus`, `vm_memory_mib`, `vm_disk_gib`, `vm_shares`, optional `vm_hostdevs` for PCI passthrough). `libvirt_vm` runs on the hypervisor (`vm_hosts`) and creates every guest that points to it.

Guests sit on an isolated bridge, NATed through the hypervisor with nftables. They cannot reach the LAN, Docker networks, IPv6 or the hypervisor itself, only the Internet. Folders are shared with virtiofs. The hypervisor's Traefik terminates TLS and forwards plain HTTP to each guest's own Traefik (see the parent repository's `group_vars/vm_hosts` and `group_vars/vms`). Moving a service group into a VM is optional and reversible through the group membership in `inventory/hosts`.

Order: `just math-create-vms`, then `just math-bootstrap <vm>`, then MASH on the guest. Values a host reads from another host (such as `vm_*` and `my_domain`) must be literals or local formulas: Ansible 2.19 fails with `hostvars is undefined` on nested lookups.
