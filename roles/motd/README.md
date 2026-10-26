# motd

Installs `/etc/update-motd.d/1-hostname`, which prints the ASCII banner `motd_banner`, and removes `/etc/update-motd.d/10-uname` (list: `motd_removed_scripts`). Override `motd_banner` in `group_vars` or `host_vars`.
