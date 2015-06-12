#!/bin/zsh
clear
print -P "$(
cat <<EOF
This script will do the following:
 - Change default shell to %B/bin/zsh%b
 - Add %B\"Recent Applications\"%b stack to dock
 - Set the following defaults:
 -- %BEnable%b scroll-to-open on dock
 -- %BEnable%b key repeat
 -- %BDefault%b to expanded save panel
 - Install %Bhomebrew%b
 -- Brew install python3, git, and vim
 - Install %Bprezto%b
EOF
)"
read -q input\?"Continue? [yn] "
echo
[[ $input == n ]] && exit
echo
# Uninstall oh-my-zsh
if (( $+commands[uninstall_oh_my_zsh] )); then
	echo "%B>>> Uninstalling oh-my-zsh%b"
	uninstall_oh_my_zsh
fi
echo "%B>>> Changing default shell to /bin/zsh%b"
chsh -s /bin/zsh

# Setup defaults
echo "%B>>> Writing defaults%b"
defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }'
echo "Added recents folder"
defaults write com.apple.dock scroll-to-open -bool TRUE
echo "Enabled scroll-to-open"
defaults write -g ApplePressAndHoldEnabled -bool false
echo "Enabled key repeat"
defaults write -g NSNavPanelExpandedStateForSaveMode -boolean true
echo "Enabled expanded save panel"
echo "%B>>> Restarting Dock%b"
killall Dock

# Setup prezto
echo "%B>>> Installing prezto%b"
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
echo "%B>>> Setting up .zshrc%b"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
	ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# Install homebrew
echo "%B>>> Installing brew%b"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "%B>>> Installing brew packages%b"
brew install python3 git vim

echo "Zsh is now the default shell."
