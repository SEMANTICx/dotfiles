# Package manifests

Run `backup-package-lists` to refresh `~/.config/package-manifests`. Each
manifest is written to a temporary file and atomically renamed only after its
producer succeeds. Run `chezmoi re-add ~/.config/package-manifests` afterward
to record refreshed inventories in the dotfiles source.

- `pacman-native.txt`: explicitly installed official repository packages
- `pacman-foreign.txt`: explicitly installed foreign/AUR packages
- `flatpak-apps.txt`: installed Flatpak application IDs
- `mason-tools.txt`: Neovim Mason packages
- `npm-global.txt`, `pipx-tools.txt`, `uv-tools.txt`, `cargo-tools.txt`: tools
  installed outside Pacman

Typical restoration starts with:

```sh
sudo pacman -S --needed - < pacman-native.txt
paru -S --needed - < pacman-foreign.txt
xargs -r flatpak install -y < flatpak-apps.txt
```

Review foreign and language-specific packages before reinstalling them; these
lists are inventories, not an unattended bootstrap script.
