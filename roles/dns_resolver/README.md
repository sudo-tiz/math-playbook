# dns_resolver

Manages a regular `/etc/resolv.conf` or a systemd-resolved drop-in. Quad9 is the default; override `dns_resolver_nameservers` or `dns_resolver_search_domains` as needed. Set `dns_resolver_immutable: true` to protect a regular file with the immutable attribute; this playbook enables it for its hosts.
