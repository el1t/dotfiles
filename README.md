# dotfiles
Preferences:
- MacOS
- Solarized (dark)
- Terminal.app
- zsh + prezto
- vim
- tmux

To setup these tools/defaults that I use, run

```zsh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/el1t/dotfiles/master/initialize)"
```

Setup is partially compatible with other distros (Ubuntu/Debian).

## Keyboard rebinding
Use [karabiner-elements](https://github.com/tekezo/Karabiner-Elements) for complex modifications.
- `caps_lock` to `escape` alone, `right_ctrl` with other keys
- `left_shift + a/s/d/f` to `right_ctrl` + arrow keys
- `right_shift + h/j/k/l` to arrow keys
- `right_shift -> left_shift` to `caps_lock`
- ["Space cadet"](http://stevelosh.com/blog/2012/10/a-modern-space-cadet/#shift-parentheses) parens

```zsh
cp ./.config/karabiner/assets/complex_modifications/custom.json ~/.config/karabiner/assets/complex_modifications
```
