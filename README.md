### 1. Download and Install Hack Nerd Font Manually

First, create the necessary directories and navigate into them:

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

wget [https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip)
unzip Hack.zip
fc-cache -fv

git clone [https://github.com/StianNOR/Homelab.git](https://github.com/StianNOR/Homelab.git)
cd Homelab
sudo chmod +x *.sh
./setup_zsh.sh
