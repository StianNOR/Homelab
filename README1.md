## 1. Download and Install Hack Nerd Font Manually

These commands will create the necessary font directories, navigate into them, download the font, unzip it, and refresh your font cache.

```bash
# Make dir for Nerd Font install
cd ~ # Ensure you are in your home directory
mkdir -p .local/share/fonts
cd .local/share/fonts

# Install Nerd Fonts Hack to get symbols and nice look
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
fc-cache -fv
