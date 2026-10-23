# math-playbook

Run from `server/`:

- `just math-bootstrap` — apply all roles.
- `just math-full-upgrade` — upgrade packages within the current OS release; APT may remove packages.
- `just math-reboot` — explicitly reboot the server and wait for it to return.
- `just math-run-tags role-dns_resolver` — apply one role.
- `just math-run-tags role-msmtp_relay` — configure host mail through MASH's Exim relay.
- `just math-run-tags role-apt_upgrade_helpers` — configure APT bug, changelog and restart helpers.
- `just math-run-tags <tag>` — run a role or task tag directly.

Requires the Ansible community package (not only `ansible-core`): the roles use `ansible.posix` and `community.general`.

Roles are idempotent and can be rerun. `fast_linux_config_version` defaults to commit `d3aef251e1d1d5ad5078e273d17a03f870001ebf`. To follow the branch instead, set this in the target's inventory:

```yaml
fast_linux_config_version: main
```

The dotfiles role targets Debian-family hosts and sets the selected users' login shell to Zsh. Existing dotfiles are backed up when replaced.

Use the shared `server/inventory` source. The root `justfile` syncs it to this playbook before each run. Math-specific host values are merged into `inventory/host_vars/<host>/vars.yml`; set `system_mail_recipient` there to receive changelog mail. Shared `group_vars` are versioned in `server/inventory/group_vars`.

`apt_full_upgrade` and `reboot_server` are deliberately excluded from `math-bootstrap`. `math-full-upgrade` does not perform a Debian/Ubuntu release upgrade.
