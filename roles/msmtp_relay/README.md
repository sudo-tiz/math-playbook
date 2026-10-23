# msmtp_relay

Installs `msmtp-mta`, which provides `/usr/sbin/sendmail`, and routes host mail to the SMTP relay. Defaults to MASH's loopback endpoint `127.0.0.1:25`; set `msmtp_relay_from` to a sender address accepted by Exim. No local SMTP daemon is started.
