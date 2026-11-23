# fail2ban

Installs and owns Fail2Ban on `math_servers`. SSH is enabled by default; Vaultwarden, Traefik, Nextcloud, Servarr, Jellyfin, Seerr and qBittorrent jails are configurable through `math_fail2ban_service_jails`. Set each `journalmatch` to the relevant systemd unit. App jails default to 5 failures in 10 minutes and a 24-hour ban; the Traefik bot jail bans on one matching User-Agent request. Docker bans use `DOCKER-USER` and affect all forwarded Docker traffic; Fail2Ban starts after Docker when any Docker jail is enabled. Docker-service jails ignore loopback, private, ULA and CGNAT addresses so an untrusted app proxy address cannot ban itself; forwarded client-IP support must still be configured in each app for public IPs to be banned.

Traefik's `common` access-log format includes the User-Agent.

Validate with `fail2ban-client -t`; test filters with `fail2ban-regex systemd-journal math-services` and `fail2ban-regex systemd-journal traefik-bots`. If Traefik is behind a CDN or proxy, configure bans there instead: the host firewall sees the proxy's source IP.
