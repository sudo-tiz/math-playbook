# nftables_firewall

Default-drop `input` firewall for the host, in its own table `inet math_firewall`. Other `/etc/nftables.d/*.nft` snippets (for example from `libvirt_vm`) are included at boot. `nftables.conf` never flushes the ruleset, so Docker's iptables-nft tables are left alone.

Allowed on input: established traffic, loopback, ICMP, `nftables_firewall_trusted_interfaces`, `nftables_firewall_ssh_port` (default `ansible_port`), `nftables_firewall_tcp_ports`, `nftables_firewall_udp_ports` (default `[68]` for DHCP). Ports published by Docker are forwarded, not input, so they are not affected.

Manual-only role (not in `bootstrap`); enabled for hosts in the `firewall_hosts` group. Run it with `just math-run-tags role-nftables_firewall` while keeping a second SSH session open.
