# larbuste

Installs Neovim, tmux, Zsh and Git, then applies the repository dotfiles to `larbuste_users`. Defaults to a pinned commit; set `larbuste_version: main` in inventory to follow the branch. Existing dotfiles are backed up. The role also sets users' login shell to Zsh by default. Dotfile copying is skipped in Ansible check mode because the Git checkout is not materialized there.
