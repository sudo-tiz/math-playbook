# math-playbook

![Ansible](https://img.shields.io/badge/Ansible-EE0000?logo=ansible&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=white)
![KVM](https://img.shields.io/badge/KVM-libvirt-orange)

Ansible roles for what [MASH](https://github.com/mother-of-all-self-hosting/mash-playbook) doesn't manage on a Debian-family server. Meant to share MASH's inventory.

Roles are idempotent, one concern each, tagged `role-<name>` (`bootstrap` for first setup). Details in `roles/<name>/README.md`.

| Role | Does | Bootstrap |
|------|------|:---------:|
| `dns_resolver` | resolv.conf / systemd-resolved | ✅ |
| `larbuste` | Neovim, tmux, Zsh, Git, dotfiles | ✅ |
| `fstab_mounts` | fstab entries (ext4, virtiofs…) | ✅ |
| `system_timezone` | timezone | ✅ |
| `msmtp_relay` | `sendmail` via MASH's Exim relay | ✅ |
| `apt_upgrade_helpers` | apt-listchanges, needrestart, apt-listbugs | ✅ |
| `unattended_upgrades` | automatic security upgrades | ✅ |
| `apt_full_upgrade` | on-demand APT full-upgrade | ➖ |
| `reboot_server` | reboot and wait | ➖ |
| `nftables_firewall` | default-drop input firewall | ➖ |
| `libvirt_vm` | KVM guests, isolated NAT network | ➖ |

## Usage

Run from `JARDIN/`, which syncs the shared inventory first. Requires the Ansible community package (`ansible.posix`, `community.general`, `community.libvirt`).

```sh
just math-bootstrap [host]       # bootstrap roles; host or group (default math_servers)
just math-full-upgrade [host]    # APT full-upgrade within the current release
just math-reboot                 # reboot and wait
just math-create-vms [vm]        # firewall then VMs (tag create-vms)
just math-run-tags <tag>         # one role or tag; math-list-tags lists them
```

Non-bootstrap roles need an explicit command.

## Inventory

Shared `JARDIN/inventory`, copied to `inventory/` (git-ignored) before each run. Host values go in `host_vars/<host>/vars.yml`; see `examples/`. `setup.yml` plays `math_servers`, then `firewall_hosts`, then `vm_hosts`.

`group_vars/math_servers` sets the defaults; override them in `host_vars`:

- `larbuste_version: main` (the role itself pins a commit)
- `larbuste_users`: SSH user and `root`
- `msmtp_relay_from`: `<host>@<mail_domain>`, from `group_vars/base`

## VMs

A VM is a host of the `vms` group describing itself in its `host_vars`: `vm_hypervisor`, `vm_user`, `vm_network`, `vm_ip`, `vm_vcpus`, `vm_memory_mib`, `vm_disk_gib`, `vm_shares`, optional `vm_hostdevs`.

`libvirt_vm` creates the guests of each `vm_hosts` hypervisor on an isolated bridge, NATed with nftables: Internet only, no LAN, Docker or host access. The hypervisor's Traefik terminates TLS and forwards HTTP to the guest.

1. `just math-create-vms`
2. `just math-bootstrap <vm>`
3. MASH on the guest

> [!NOTE]
> Values read across hosts (`vm_*`, `my_domain`) must be literals: Ansible 2.19 fails on nested `hostvars` lookups.
