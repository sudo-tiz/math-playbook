# math-playbook

Ansible roles for what [MASH](https://github.com/mother-of-all-self-hosting/mash-playbook) doesn't manage on a Debian-family server: host setup, mail relay, APT upgrades, firewall, KVM VMs. Meant to share MASH's inventory.

Roles are idempotent, one concern each, tagged `role-<name>` (`bootstrap` for first setup). Details in `roles/<name>/README.md`.

| Role | Does | Bootstrap |
|------|------|-----------|
| `dns_resolver` | resolv.conf / systemd-resolved | yes |
| `fast_linux_config` | Neovim, tmux, Zsh, Git, dotfiles | yes |
| `fstab_mounts` | fstab entries (ext4, virtiofs…) | yes |
| `system_timezone` | timezone | yes |
| `msmtp_relay` | `sendmail` via MASH's Exim relay | yes |
| `apt_upgrade_helpers` | apt-listchanges, needrestart, apt-listbugs | yes |
| `unattended_upgrades` | automatic security upgrades | yes |
| `apt_full_upgrade` | on-demand APT full-upgrade | no |
| `reboot_server` | reboot and wait | no |
| `nftables_firewall` | default-drop input firewall | no |
| `libvirt_vm` | KVM guests, isolated NAT network | no |

## Usage

From `server/` (it syncs the shared inventory first):

- `just math-bootstrap [host]`: bootstrap roles; `host` is a host or group (default `math_servers`).
- `just math-full-upgrade [host]`: APT full-upgrade within the current release.
- `just math-reboot`: reboot and wait.
- `just math-create-vms [vm]`: firewall then VMs (tag `create-vms`).
- `just math-run-tags <tag>`: one role or tag. `just math-list-tags` lists them.

Non-bootstrap roles need an explicit command. Requires the Ansible community package (`ansible.posix`, `community.general`, `community.libvirt`).

## Inventory

Shared `server/inventory`, copied to `inventory/` (git-ignored) before each run. Host values go in `host_vars/<host>/vars.yml`; see `examples/`. `setup.yml` plays: `math_servers`, then `firewall_hosts`, then `vm_hosts`.

`group_vars/math_servers` sets defaults: `fast_linux_config_version: main` (the role itself pins a commit), `fast_linux_config_users` (SSH user and `root`), `msmtp_relay_from` (`<host>@<mail_domain>`, from `group_vars/base`). Override in `host_vars`.

## VMs

A VM is a host of the `vms` group describing itself in its `host_vars` (`vm_hypervisor`, `vm_user`, `vm_network`, `vm_ip`, `vm_vcpus`, `vm_memory_mib`, `vm_disk_gib`, `vm_shares`, optional `vm_hostdevs`). `libvirt_vm` creates the guests of each `vm_hosts` hypervisor on an isolated bridge, NATed with nftables: Internet only, no LAN, Docker or host access. The hypervisor's Traefik terminates TLS and forwards HTTP to the guest.

Order: `just math-create-vms`, `just math-bootstrap <vm>`, then MASH on the guest. Values read across hosts (`vm_*`, `my_domain`) must be literals: Ansible 2.19 fails on nested `hostvars` lookups.
