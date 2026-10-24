# math-playbook

Run from `server/`:

- `just math-bootstrap` — apply all roles.
- `just math-full-upgrade` — upgrade packages within the current OS release; APT may remove packages.
- `just math-reboot` — explicitly reboot the server and wait for it to return.
- `just math-run-tags role-dns_resolver` — apply one role.
- `just math-run-tags role-msmtp_relay` — configure host mail through MASH's Exim relay.
- `just math-create-vms [vm]` — firewall then VMs (tag `create-vms`: `nftables_firewall` + `libvirt_vm`); `vm` limits it to one guest.
- `just math-run-tags role-nftables_firewall` — host input firewall for `firewall_hosts` (manual only; keep a second SSH session open).
- `just math-run-tags role-libvirt_vm` — create the VMs of `vm_hosts` (manual only; run before bootstrapping the guests).
- `just math-run-tags role-apt_upgrade_helpers` — configure APT bug, changelog and restart helpers.
- `just math-run-tags <tag>` — run a role or task tag directly.

Requires the Ansible community package (not only `ansible-core`): the roles use `ansible.posix` and `community.general`.

Roles are idempotent and can be rerun. The `fast_linux_config` role defaults `fast_linux_config_version` to commit `d3aef251e1d1d5ad5078e273d17a03f870001ebf`, but the shared `server/inventory/group_vars/math_servers` sets it to `main` (follow the branch). To pin a host to a commit, set this in its `host_vars`:

```yaml
fast_linux_config_version: d3aef251e1d1d5ad5078e273d17a03f870001ebf
```

`group_vars/math_servers` also derives `fast_linux_config_users` (the SSH user and `root`), `msmtp_relay_from` (`<host>@<mail_domain>`, `mail_domain` comes from `group_vars/base`) and `msmtp_relay_host/port`; override them in `host_vars` when needed.

The dotfiles role targets Debian-family hosts and sets the selected users' login shell to Zsh. Existing dotfiles are backed up when replaced.

Use the shared `server/inventory` source. The root `justfile` syncs it to this playbook before each run. Math-specific host values are merged into `inventory/host_vars/<host>/vars.yml`; set `system_mail_recipient` there to receive changelog mail. Shared `group_vars` are versioned in `server/inventory/group_vars`.

`apt_full_upgrade` and `reboot_server` are deliberately excluded from `math-bootstrap`. `math-full-upgrade` does not perform a Debian/Ubuntu release upgrade.
