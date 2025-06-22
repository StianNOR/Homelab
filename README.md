#Download and install Hack Nerd Font manually

`mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
fc-cache -fv`

#Install my Homelab

`git clone https://github.com/StianNOR/Homelab.git
cd Homelab
sudo chmod +x *.sh
./setup_zsh.sh`
