# fstab_mounts

Manages the configured `/etc/fstab` entries and mounts each filesystem immediately. Entries need `src` and `path`; defaults are `ext4`, `defaults`, `dump: "0"`, and `passno: "0"`. Optional `owner`, `group`, and `mode` values are applied to the mounted filesystem root after mounting.
