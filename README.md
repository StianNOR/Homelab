## Welcome to My Script to Make Your Terminal Life Easier on Linux. :sparkles:
<br><br>

### The script supports Linux distros using these package managers:
| Package Manager | Distro |
|---------|----------------|
| APT     | Debian, Ubuntu, LinuxMint, PopOS, Deepin, etc  |
| DNF     | Fedora, CentOS 8+, RHEL 8+, Rocky Linux, AlmaLinux, etc  |
| YUM     | CentOS 7, older RHEL versions, Oracle Linux, etc  |
| Pacman  | Arch Linux, Manjaro, EndeavourOS, Artix Linux, etc      |
| Zypper  | openSUSE, SUSE, etc     |

<br><br>
#### 1. Download and Install Hack Nerd Font Manually.
These commands will create the font directories, download the font, unzip it, and refresh your font cache.
Nerd Fonts add nice symbols for your terminal.
```
cd ~                # Go to home directory
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
#### 3. Clone and Install Homelab.
```
cd ~          # Go to home directory
git clone https://github.com/StianNOR/Homelab.git
cd Homelab
sudo chmod +x *.sh
./setup_zsh.sh
```
<br><br>
#### 4. Uninstall
##### To remove Portainer and Docker, run:
```
./portainer_docker_uninstall.sh
```
<br><br>
##### o uninstall the Zsh setup (restart terminal after uninstall):
```
./uninstall_zsh_setup.sh
```

<br><br>
> [!TIP]
> Helpful advice for doing things better or more easily.
<br><br>
##### To show currently used zsh aliases:
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

<br><br>
<br><br>

> [!CAUTION]
> Disclaimer

This script is provided as-is and is intended for use on supported Linux distributions. While it has been tested on common distros, it may cause issues or break your system depending on your configuration.
Use at your own risk. It is strongly recommended to back up any important data before running this script.
The author is not responsible for any data loss, system damage, or other issues that may result from using this script.
If unsure, test in a safe environment like a virtual machine before using on your main system.


