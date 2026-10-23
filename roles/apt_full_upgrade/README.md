# apt_full_upgrade

Runs APT full-upgrade on demand. This upgrades packages within the current Debian/Ubuntu release; it does not change the OS release and may remove packages to resolve dependencies. Run only with `just math-full-upgrade`, not during bootstrap. With `apt_full_upgrade_reboot_if_required=true` (set by `just periodic-update`), it reboots only if `/var/run/reboot-required` exists or `needrestart -b -k` reports a pending kernel upgrade.
