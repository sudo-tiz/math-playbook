# fstab_mounts

Manages the configured filesystems in one `# BEGIN/END ANSIBLE MANAGED BLOCK fstab_mounts` block of `/etc/fstab` and mounts each one immediately. Removing an entry from `fstab_mounts_entries` removes its line from the block on the next run; it is not unmounted (unmount it by hand or reboot).

Entries need `src` and `path`; defaults are `ext4`, `defaults`, `dump: "0"`, and `passno: "0"`. `opts` replaces `defaults` (write `defaults,nofail` to keep it). The mount point is created if missing. Optional `owner`, `group`, and `mode` values are applied to the mounted filesystem root after mounting.

Lines already in `/etc/fstab` outside the block are not touched: delete them by hand once, or the mount point appears twice.
