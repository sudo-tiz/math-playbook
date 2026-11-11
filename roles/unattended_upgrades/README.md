# unattended_upgrades

Enables Debian-family unattended upgrades and the APT upgrade timer. Automatic reboot is disabled by default and controlled by `unattended_upgrades_automatic_reboot`.

Set `unattended_upgrades_mail_to` (empty = no mail) to get a report per `unattended_upgrades_mail_report` (default `on-change`). Needs `msmtp_relay` for `sendmail`.
