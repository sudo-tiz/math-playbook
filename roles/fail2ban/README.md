# fail2ban

Installs and owns Fail2Ban on `math_servers`. SSH is enabled by default; Vaultwarden, Traefik, Nextcloud, Servarr, Jellyfin, Seerr and qBittorrent jails are configurable through `math_fail2ban_service_jails`. Set each `journalmatch` to the relevant systemd unit. App jails default to 5 failures in 10 minutes and a 24-hour ban. Traefik bans one matching User-Agent request or five sensitive-path 404 probes in 2 minutes. Docker bans use `DOCKER-USER` and affect all forwarded Docker traffic; Fail2Ban starts after Docker when any Docker jail is enabled. Docker-service jails ignore loopback, private, ULA and CGNAT addresses so an untrusted app proxy address cannot ban itself; forwarded client-IP support must still be configured in each app for public IPs to be banned.

Traefik drops request headers from access logs by default. Keep only the User-Agent with `accessLog.fields.headers.defaultMode: drop` and `accessLog.fields.headers.names.User-Agent: keep`.

The Traefik bot jail blocks the configured User-Agent pattern plus 699 blocked patterns from [Nginx Ultimate Bad Bot Blocker](https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker), snapshot `V4.2026.11.6272` (2026-11-24). The snapshot is static and is not fetched at runtime; the list is stored in `files/traefik-badbots.regex` and carries its upstream MIT license notice alongside it.

Validate with `fail2ban-client -t`; test filters with `fail2ban-regex systemd-journal math-services`, `fail2ban-regex systemd-journal traefik-bots` and `fail2ban-regex systemd-journal traefik-probes`. If Traefik is behind a CDN or proxy, configure bans there instead: the host firewall sees the proxy's source IP.
