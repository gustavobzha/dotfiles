#!/bin/bash

yes | sudo pacman -Syyu


yes | sudo pacman -S feh rofi lxappearance maim arandr dmenu xdotool gucharmap bdf-unifont ttf-anonymous-pro xorg-xfd python-mpd2 python-iwlib khal playerctl wget unzip neovim nodejs npm fzf ranger ripgrep xclip yarn python-pipenv the_silver_searcher tmux neofetch zsh zshdb powerline-fonts dos2unix linux-headers ttf-font-awesome

yay -S pygtk ptxconf-git nerd-fonts-complete mpris-ctl polybar-git zscroll-git openrazer-meta polychromatic rofi-file-browser-extended-git autojump 

sh -c "$(curl -fsSL https://starship.rs/install.sh)"

mkdir -p $HOME/.local/share/fonts
mv fonts/* $HOME/.local/share/fonts/
fc-cache -fv
mv polybar/* $HOME/.config/polybar/
chmod +x $HOME/.config/polybar/launch.sh
mv /i3/* $HOME/.config/i3/
feh --bg-scale $HOME/.config/i3/wallpaper.jpg
mv rofi/* $HOME/.config/rofi/


mv .tmux.conf ~/.tmux.conf
mv .vim ~/.vim 
mv nvim ~/.config/

# Download Plug, Vim Plug Manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Download tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install autojump
git clone git://github.com/wting/autojump.git
cd autojump
sudo ln -s /usr/bin/python3 /usr/bin/python
./install.py
cd ..
rm -rf autojump

# Starship cross-shell prompt for bash
sh -c "$(curl -fsSL https://starship.rs/install.sh)"

#Install Vim Plugins and Coc Plugins
nvim -c ':PlugInstall | quit | quit | quit'
# Set zshell as default
chsh -s $(which zsh)
