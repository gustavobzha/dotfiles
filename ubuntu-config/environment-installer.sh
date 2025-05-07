#!/bin/bash

echo -e "\n\nInstalling basic packages\n"
sudo apt install git flatpak cherrytree gnome-browser-connector curl copyq flameshot dconf-editor i3 i3blocks arandr pavucontrol rofi ibus nitrogen net-tools alacritty ranger pulsemixer -y
# OBS: ibus for ibus-setup (keyboard layout manager)
#      nitrogen for wallpapers

echo -e "\n\nAdd flathub repo to remote source flatpak\n"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo -e "\n\nInstalling flatpak apps for personal use\n"
flatpak install com.bitwarden.desktop -y
flatpak install flathub com.obsproject.Studio -y
flatpak install flathub rest.insomnia.Insomnia -y
flatpak install flathub io.dbeaver.DBeaverCommunity -y
flatpak install flathub org.apache.jmeter -y
flatpak install flathub com.spotify.Client -y
flatpak install flathub org.soapui.SoapUI -y
flatpak install flathub com.visualstudio.code -y

echo -e "\nInstalling repository apps for personal use\n\n"
sudo apt install color-picker -y
sudo apt install kolourpaint -y
sudo apt install kruler -y
sudo apt install meld -y
sudo apt install neovim -y

echo -e "\n\nInstalling libfuse2 for webapps\n"
sudo apt install libfuse2

echo -e "\n\nConfigure aliases on .bashrc\n\n"
cat >> $HOME/.bashrc <<EOF 
# COLORFUL COMMANDS
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias ls='ls --color=auto'
alias tree='tree -C'

#List ports
alias list-ports='sudo lsof -i -P -n | head -n 1 && sudo lsof -i -P -n | grep LISTEN'

#List services
alias list-active-services='systemctl list-units --type=service --state=active'

#Aliases for kubernetes
alias k='kubectl'
alias kaf='k apply -f'
alias kg='k get'
alias kgp='kg pods'
alias kgs='kg service'
alias kgst='kg secret'
alias kgi='kg ingress'
alias kgd='kg deploy'
alias kd='k describe'
alias kgj='kg job'
alias k8s-shell='kubectl -n default run network-debug-${RANDOM} --rm -it --image=praqma/network-multitool:alpine-extra -- /bin/bash'

# Listar apenas os nomes de todos os containers.
alias dcontainers="docker ps -a --format '{{.Names}}'" 

# Remove docker images with name <none>
alias docker-remove-none='docker rmi $(docker images -f "dangling=true" -q)'

# Taskbook
alias ct='taskbook --task'

export LESS='-R --use-color -Dd+r$Du+b$'
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"
EOF

echo -e "\n\nInstalling and configuring FZF\n"
sudo apt install fzf -y
echo -e "\n\nsource /usr/share/doc/fzf/examples/key-bindings.bash" >> .bashrc


echo -e "Installing Nerd fonts\n"
declare -a fonts=(
    DroidSansMono
    FiraCode
    FiraMono
    Hack
    Meslo
    Noto
    RobotoMono
    SpaceMono
    Ubuntu
    UbuntuMono
    NerdFontsSymbolsOnly
)

version='3.3.0'
fonts_dir="${HOME}/.local/share/fonts"

if [[ ! -d "$fonts_dir" ]]; then
    mkdir -p "$fonts_dir"
fi

for font in "${fonts[@]}"; do
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
    echo "Downloading $download_url"
    wget "$download_url"
    unzip "$zip_file" -d "$fonts_dir" -o
    rm "$zip_file"
done

find "$fonts_dir" -name '*Windows Compatible*' -delete

fc-cache -fv


echo -e "\n\nInstall dependencies for Pano Clipboard manager gnome extension\n"
sudo apt install gir1.2-gda-5.0 gir1.2-gsound-1.0 -y

echo -e "\n\nInstall dependencies for Vitals gnome extension\n"
sudo apt install gir1.2-gtop-2.0 lm-sensors -y

if [[ ! -f "$HOME/.config/starship.toml" ]]; then
	echo -e "\n\nInstalling Starship shell prompt\n"
	curl -sS https://starship.rs/install.sh | sh

	cat >> $HOME/.config/starship.toml <<EOF 
	format = '\$all\$fill\$time\$line_break\$jobs\$status\$os\$container\$shell\$character'

	[python]
	python_binary = 'python3'

	[time]
	disabled = false
	format = ' [\$time](\$style) '

	[fill]
	symbol = '-'
	style = 'bold white'
EOF

	echo -e '\neval "$(starship init bash)"' >> ~/.bashrc
fi

echo -e "\nConfigure Xresources\n\n"
mv .Xresources ~/.Xresources

echo -e "\nConfigure screenlayout\n\n"
mv .screenlayout ~/.screenlayout

echo -e "\nConfigure i3wm\n"
mv i3 ~/.config/
mv i3blocks ~/.config/

echo -e "\nConfigure Neovim\n\n"
mv .vim ~/.vim
mv nvim ~/.config/

# Download Plug, Vim Plug Manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

#Install Vim Plugins and Coc Plugins
nvim -c ':PlugInstall | quit | quit | quit'

echo -e "\n\nexport EDITOR=nvim" >> ~/.bashrc


echo -e "\nConfiguring Swap size to 16GB"
cp /etc/fstab /etc/fstab.backup

# Verify if scripts is executing as root
#if [[ $EUID -ne 0 ]]; then
#    echo "This script must be run as root. Use sudo."
#    exit 1
#fi

# Verify if exist sufficient space to create swapfile
FREE_SPACE=$(df -h / | awk 'NR==2 {print $4}')
if [[ ${FREE_SPACE%G} -lt 16 ]]; then
    echo "Not enough disk space to create a 16GB swapfile. Free space: $FREE_SPACE"
    exit 1
fi

# Create new swapfile with 16GB size
echo "Creating new 16GB swapfile at /swapfile..."
if ! sudo fallocate -l 16G /swapfile; then
    echo "Failed to create swapfile. Exiting."
    exit 1
fi

sudo chmod 600 /swapfile
if ! sudo mkswap /swapfile; then
    echo "Failed to format swapfile. Exiting."
    sudo rm -f /swapfile
    exit 1
fi

# Verify is exits active swapfile
OLD_SWAPFILE=$(sudo swapon --show | tail -n 1 | awk '{print $1}')
if [[ -z "$OLD_SWAPFILE" ]]; then
    echo "No active swapfile found. Adding /swapfile to /etc/fstab..."
    echo "/swapfile	none	swap	sw	0	0" | sudo tee -a /etc/fstab > /dev/null
else
    echo "Old swapfile found: $OLD_SWAPFILE"

    # Disable current swapfile
    echo "Deactivating old swapfile..."
    if ! sudo swapoff "$OLD_SWAPFILE"; then
        echo "Failed to deactivate old swapfile. Exiting."
        exit 1
    fi

    # Update /etc/fstab to use new swapfile
    echo "Updating /etc/fstab to use /swapfile..."
    sudo sed -i -e "s|^$OLD_SWAPFILE|/swapfile|" /etc/fstab

    # Remove old swapfile
    echo "Removing old swapfile..."
    sudo rm -f "$OLD_SWAPFILE"
fi

# Activate new swapfile
echo "Activating new swapfile..."
if ! sudo swapon /swapfile; then
    echo "Failed to activate new swapfile. Exiting."
    exit 1
fi

echo "New Swap /swapfile configuration updated successfully."


echo -e "\nDownload Dropbox dependency\n"
sudo apt install python3-gpg

echo -e "\n Download Dropbox\n\n"
wget -O dropbox.deb  https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2024.04.17_amd64.deb || echo "Unable to download dropbox.deb"

if [[ -a "dropbox.deb" ]]; then
  echo "Installing dropbox with DPKG"
  sudo dpkg -i dropbox.deb
else
  echo "Dropbox will not install due to previous errors";
fi

# Install rofi custom themes/applets
git clone --depth=1 https://github.com/gustavobzha/rofi.git
cd rofi
sudo chmod +x setup.sh
./setup.sh
cd ..
rm -rf rofi

echo -e "\nConfiguration Gnome shortcuts"
# Change default shortcuts
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>T']"
gsettings set org.gnome.settings-daemon.plugins.media-keys mic-mute "['Launch7']"

### Creating custom shortchuts

# File Manager
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Nautilus'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'nautilus'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>e'

# Flameshot
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Flameshot'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'flatpak run org.flameshot.Flameshot gui'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Shift><Super>s'
