## Simplify and beautify your Linux terminal experience with this handy script. :sparkles:
<br><br>

### The script supports Linux distros using these package managers: ✅
| Package Manager | Distro |
|---------|----------------|
| APT     | Debian, Ubuntu, LinuxMint, PopOS, Deepin, etc  |
| DNF     | Fedora, CentOS 8+, RHEL 8+, Rocky Linux, AlmaLinux, etc  |
| YUM     | CentOS 7, older RHEL versions, Oracle Linux, etc  |
| Pacman  | Arch Linux, Manjaro, EndeavourOS, Artix Linux, etc      |
| Zypper  | openSUSE, SUSE, etc     |

<br><br>
#### 1. Download and Install Hack Nerd Font Manually. ✅
These commands will create the font directories, download the font, unzip it, and refresh your font cache.
Nerd Fonts add nice symbols for your terminal.
```
cd ~ # Go to home directory, Can also check dir whit command: pwd
mkdir -p .local/share/fonts 
cd .local/share/fonts
```
<br><br>
#### 2. Install Nerd Fonts Hack. ✅
```
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
fc-cache -fv
```

##### I recommand to go system settings and search for fonts, then adjust all fonts to Hack Nerd Font. Then apply. (If not showing restart.)

<br><br>
#### 3. Clone and Install Homelab. ✅
<br><br>
### Before Installing. 🛑
<br><br>
⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
## Verifying Script Authenticity
<br><br>
#### Clone Files to be ready for Verifing:
```
cd ~ # Go to home directory, Can also check dir whit command: pwd
git clone https://github.com/StianNOR/Homelab.git
cd Homelab
sudo chmod +x *.sh
```
<br><br>
Each script is signed with my PGP key available on my [Keybase profile](https://keybase.io/sarttech7).

PGP public key fingerprint:  
`52FE58C1C8BDA54D68E09C143E305BD749B795A3`

To verify any script before running, download both the script and its `.asc` signature file, then run:
```
gpg verify signatures/setup_zsh.sh.asc -i setup_zsh.sh
gpg verify signatures/up.sh.asc -i up.sh
gpg verify signatures/portainerup.sh.asc -i portainerup.sh
gpg verify signatures/portainer_docker_uninstall.sh.asc -i portainer_docker_uninstall.sh
gpg verify signatures/uninstall_zsh_setup.sh.asc -i uninstall_zsh_setup.sh
```
⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
<br><br>
## After verifying you can go on whit installing:

```
./setup_zsh.sh
```
## If Fastfetch fails please manual install it and re run the script ./setup_zsh.sh ([https://github.com/fastfetch-cli/fastfetch])

### Please reboot or relog to make changes. ⚠️

<br><br>
#### 5. Install Portainer and Docker:
##### Now you should just type pup in terminal. Then follow prompts.
##### When prompted to reboot or relog do so, and also do `newgrp docker` if prompted.
##### Portainer and docker is ready if you get this msg:
<img width="661" height="46" alt="image" src="https://github.com/user-attachments/assets/41a5297a-fe00-41cb-acb7-67e1a98acbb5" />



<br><br>

#### 5. Uninstall 😦
##### To remove Portainer and Docker, run: 😭
```
./portainer_docker_uninstall.sh
```
<br><br>
##### To uninstall the Zsh setup (restart terminal after uninstall): 😭
```
./uninstall_zsh_setup.sh
```

<br><br>
> [!TIP]
> Helpful advice for doing things better or more easily.
<br><br>
##### To show currently used zsh aliases: 🤓
```
ali
```
<br><br>
##### Directories info shortcuts: 📝
| Command | Actual Command | Description                    |
|---------|----------------|-------------------------------|
| ls      | ls             | List files and directories     |
| ll      | ls -l          | Long format detailed listing   |
| la      | ls -a / ls -la | List all files, including hidden files |
| sls     | ls -ls         | List with file sizes and details |

<br><br>
<br><br>

> [!CAUTION]
> Disclaimer ⚠️
<br><br>

`This script is provided as-is and is intended for use on supported Linux distributions.`\
`While it has been tested on common distros, it may cause issues or break your system depending on your configuration.`\
`Use at your own risk. It is strongly recommended to back up any important data before running this script.`\
`The author is not responsible for any data loss, system damage, or other issues that may result from using this script.`\
`If unsure, test in a safe environment like a virtual machine before using on your main system.`
