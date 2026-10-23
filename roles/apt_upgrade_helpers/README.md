# apt_upgrade_helpers

Installs `apt-listchanges` and `needrestart`; also installs `apt-listbugs` on Debian (Ubuntu does not use the Debian BTS). In non-interactive APT sessions, `apt-listbugs` pins buggy package versions using its default severe-bug policy. `needrestart` automatically restarts eligible services after upgrades. Set `system_mail_recipient` in inventory to send changelog mail; without it, APT changelog output is disabled rather than prompting.
