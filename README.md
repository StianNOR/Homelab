## Welcome To my Script to make your Terminal life Easier in Linux.
<br><br>

### The provided script supports Linux distros that use the following package managers, as detected in the script:
<br><br>
| Package Manager | Distro |
|---------|----------------|
| APT     | Debian, Ubuntu, LinuxMint, PopOS, Deepin, etc  |
| DNF     | Fedora, CentOS 8+, RHEL 8+, Rocky Linux, AlmaLinux, etc |
| YUM     | CentOS 7, older RHEL versions, Oracle Linux, etc  |
| Pacman  | Arch Linux, Manjaro, EndeavourOS, Artix Linux, etc      |
| Zypper  | openSUSE, SUSE, etc     |

<br><br>
#### 1. Download and Install Hack Nerd Font Manually.
These commands will create the necessary font directories, navigate into them, download the font, unzip it, and refresh your font cache.
(NerdFont will make it look much nicer and add allot of used symboles.)
```
cd ~ # Ensure you are in your home directory
mkdir -p .local/share/fonts 
cd .local/share/fonts
```
<br><br>
#### 2. Install Nerd Fonts Hack.
```
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
fc-cache -fv
```
<br><br>
#### 3. Git Clone and install Homelab.
```
cd ~ # Ensure you are in your home directory before cloning
git clone https://github.com/StianNOR/Homelab.git
cd Homelab
sudo chmod +x *.sh
./setup_zsh.sh
```
<br><br>
#### 4. Uninstall
##### To remove portainer and docker simply run:
```
./portainer_docker_uninstall.sh
```
<br><br>
##### To uninstall setup_zsh.sh. (After Full Uninstall you need to close terminal window and open new on.)
```
./uninstall_zsh_setup.sh
```

<br><br>
> [!TIP]
> Helpful advice for doing things better or more easily.
<br><br>
##### This will show zshrc alias thats in use.
```
ali
```
<br><br>
##### Directories info shortcuts:
| Command | Actual Command | Description                    |
|---------|----------------|-------------------------------|
| ls      | ls             | List files and directories     |
| ll      | ls -l          | Long format detailed listing   |
| la      | ls -a / ls -la | List all files, including hidden files |
| sls     | ls -ls         | List with file sizes and details |
