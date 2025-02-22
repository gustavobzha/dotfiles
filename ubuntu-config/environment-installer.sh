#!/bin/bash

echo -e "\n\nInstalling basic packages\n"
sudo apt install git flatpak cherrytree gnome-browser-connector curl copyq flameshot dconf-editor -y

echo -e "\n\nAdd flathub repo to remote source flatpak\n"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo -e "\n\nInstalling flatpak apps for personal use\n"
flatpak install com.dropbox.Client -y
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

	echo -e '\neval "$(starship init bash)"' >> .bashrc
fi

echo -e "\nConfigure Neovim\n\n"
mv .vim ~/.vim
mv nvim ~/.config/

# Download Plug, Vim Plug Manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

#Install Vim Plugins and Coc Plugins
nvim -c ':PlugInstall | quit | quit | quit'
