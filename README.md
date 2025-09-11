### 1. Download and Install Hack Nerd Font Manually

These commands will create the necessary font directories, navigate into them, download the font, unzip it, and refresh your font cache.

```bash
cd ~ # Ensure you are in your home directory
mkdir -p .local/share/fonts
cd .local/share/fonts

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
fc-cache -fv

cd ~ # Ensure you are in your home directory before cloning
git clone https://github.com/StianNOR/Homelab.git
cd Homelab
sudo chmod +x *.sh
./setup_zsh.sh


# Uninstall

# To remove portainer and docker simply run.
./portainer_docker_uninstall.sh

# To uninstall everything run. (After Full Uninstall you need to close terminal window and open new on.)
./uninstall_zsh_setup.sh


# Tips my aliases type this
ali

# This will show zshrc alias thats in use.
