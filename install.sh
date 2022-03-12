#!/bin/bash

yes | sudo pacman -Syyu

yes | sudo pacman -S feh rofi lxappearance maim arandr gcolor2 dmenu xdotool gucharmap bdf-unifont ttf-anonymous-pro xorg-xfd python-mpd2 python-iwlib khal playerctl wget unzip neovim nodejs npm fzf ranger ripgrep xclip yarn python-pipenv the_silver_searcher tmux neofetch zsh zshdb powerline-fonts dos2unix linux-headers ttf-font-awesome

yay -S pygtk ptxconf-git nerd-fonts-complete mpris-ctl polybar-git zscroll-git openrazer-meta polychromatic rofi-file-browser-extended-git

#install rofi launcher themes
git clone --depth=1 https://github.com/adi1090x/rofi.git
cd rofi
chmod +x setup.sh
./setup.sh
cd ..
rm -rf rofi

mkdir -p ~/.local/share/fonts
mv fonts/* ~/.local/share/fonts/
fc-cache -fv
cp -R i3status ~/.config/i3status
mv /i3/* ~/.config/i3/
feh --bg-scale ~/.config/i3/wallpaper.jpg
mv rofi/launcher.sh ~/.config/rofi/launchers/colorful/

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

#Install Vim Plugins and Coc Plugins
nvim -c ':PlugInstall | quit | quit | quit'
# Set zshell as default
chsh -s $(which zsh)

#Install Zinit - plugin manager for zsh
sh -c "$(curl -fsSL https://git.io/zinit-install)"

# Add some Zsh configs
cat zsh_config >> ~/.zshrc