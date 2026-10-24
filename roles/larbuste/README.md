# larbuste

Installs Neovim, tmux, Zsh and Git, then applies the repository dotfiles to `larbuste_users`. Defaults to a pinned commit; set `larbuste_version: main` in inventory to follow the branch. Existing dotfiles are backed up. The role also sets users' login shell to Zsh by default. Dotfile copying is skipped in Ansible check mode because the Git checkout is not materialized there.

## Users

```yaml
larbuste_users:
  - name: alice                # all dotfiles
  - name: bob
    dotfiles: [.bashrc, .zshrc, init.lua]   # allowlist of `src` from larbuste_dotfiles (no tmux)
    set_login_shell: false     # default: larbuste_set_login_shell
```

| Variable | Default | Purpose |
|---|---|---|
| `larbuste_users` | `[]` | Users to configure (required) |
| `larbuste_repository` / `larbuste_version` | LARBUSTE repo / pinned commit | Dotfiles source |
| `larbuste_checkout_path` | `/usr/local/src/larbuste` | Checkout location |
| `larbuste_packages` | git, neovim, tmux, zsh | Installed packages |
| `larbuste_dotfiles` | see `defaults/main.yml` | `src` (in repo) → `dest` (in `$HOME`) |
| `larbuste_set_login_shell` | `true` | Default login-shell switch to Zsh |

Layout: `tasks/main.yml` imports `validate.yml`, installs packages, fetches the checkout, then runs `user.yml` once per user.

Unknown `dotfiles` entries fail the run. Only the directories needed by a user's selected dotfiles are created.
