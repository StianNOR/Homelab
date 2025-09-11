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
### 1. Download and Install Hack Nerd Font Manually. ✅
These commands will create the font directories, download the font, unzip it, and refresh your font cache.
Nerd Fonts add nice symbols for your terminal.
```
cd ~ # Go to home directory, Can also check dir whit command: pwd
mkdir -p .local/share/fonts 
cd .local/share/fonts
```
<br><br>
### 2. Install Nerd Fonts Hack. ✅
```
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
fc-cache -fv
```

#### I recommand to go system settings and search for fonts, then adjust all fonts to Hack Nerd Font. Then apply. (If not showing restart.)

<br><br>

### 3. Clone Verify and Install Homelab. ✅

<br><br>

### Verifying Script Authenticity ⚠️

<br><br>

#### Each script in this repository is digitally signed with my special security key managed on Keybase.  
This means you can check that the scripts really come from me and haven't been changed by anyone else.

<br><br>

#### Clone and Prepare for Verification ⚠️

```
cd ~ # Go to home directory, Can also check dir whit command: pwd
git clone https://github.com/StianNOR/Homelab.git
cd Homelab
sudo chmod +x *.sh
```

<br><br>

#### Import My Public Key ✅

PGP public key fingerprint:  
`52FE58C1C8BDA54D68E09C143E305BD749B795A3`

To verify any script before running: ✅

####  Import my GPG public key:
```
curl https://keybase.io/sarttech7/pgp_keys.asc | gpg --import
```
#### This imports my current PGP public key with fingerprint: ✅
```
52FE 58C1 C8BD A54D 68E0 9C14 3E30 5BD7 49B7 95A3
```
#### Verifying Scripts: ✅
```
gpg --verify signatures/setup_zsh.sh.asc setup_zsh.sh
gpg --verify signatures/up.sh.asc up.sh
gpg --verify signatures/portainerup.sh.asc portainerup.sh
gpg --verify signatures/portainer_docker_uninstall.sh.asc portainer_docker_uninstall.sh
gpg --verify signatures/uninstall_zsh_setup.sh.asc uninstall_zsh_setup.sh
```
### You should see an output like: ✅
```
Good signature from "StianNOR <stiannor@duck.com>"
```
> [!IMPORTANT]
> GPG may show a warning:  
`WARNING: This key is not certified with a trusted signature!  
There is no indication that the signature belongs to the owner.
`
> This means GPG does not yet fully trust my key by default.  
> This is not a security flaw but part of GPG’s trust model.  
> You can eliminate the warning by marking my key as trusted locally:  
```
gpg --edit-key 3E305BD749B795A3
# Then type:
trust
# Select option 5 (ultimate trust)
y
quit
```
#### Note: Only mark keys you personally verify as ultimately trusted. ⚠️

> Why Trust Matters  
> The trust model in GPG prevents blindly trusting keys or signatures.  
> My Keybase profile provides an additional identity assurance layer,  
> but users must assign trust locally to verify authenticity fully.

<br><br>

#### After verifying you can go on whit installing: ✅

```
./setup_zsh.sh
```
### Please reboot or relog to make changes. ✅

<br><br>
### 4. Install Portainer and Docker: ✅ (You dont need to install Docker and Portainer if not using it.)
<br><br>
Now you should just type pup in terminal. Then follow prompts.
When prompted to reboot or relog do so, and also do `newgrp docker` if prompted.
Portainer and docker is ready if you get this msg:
<br><br>
<img width="661" height="46" alt="image" src="https://github.com/user-attachments/assets/41a5297a-fe00-41cb-acb7-67e1a98acbb5" />
<br><br>
### If you installed Portainer and Docker you can in future use command `pup` to also update portainer.

<br><br>

### 5. Uninstall (Uninstall scripts are located in /home/$USER/Homelab.) 😦
#### To remove Portainer and Docker, run: 😭
```
./portainer_docker_uninstall.sh
```

<br><br>

#### To uninstall the Zsh setup (restart terminal after uninstall): 😭
```
./uninstall_zsh_setup.sh
```

<br><br>

> [!TIP]
> Helpful advice for doing things better or more easily.
<br><br>
#### To show currently used zsh aliases: 🤓
```
ali
```

<br><br>

#### Directories info shortcuts: 📝
| Command | Actual Command | Description                    |
|---------|----------------|-------------------------------|
| ls      | ls             | List files and directories     |
| ll      | ls -l          | Long format detailed listing   |
| la      | ls -a / ls -la | List all files, including hidden files |
| sls     | ls -ls         | List with file sizes and details |

<br><br>

> [!NOTE]
With best regards,  
StianNOR  
(Known as sarttech7 on Keybase)  
https://keybase.io/sarttech7  

<br><br>
<br><br>

> [!CAUTION]
> Disclaimer ⚠️
<br><br>
> This script is provided as-is and intended to be used on supported Linux distributions.  
> While it has been tested on common setups, it may not work perfectly on every system and could cause issues or damage depending on your configuration.
<br><br>
> Use it at your own risk. Please back up any important data before running these scripts. The author is not responsible for any loss or damage.
<br><br>
> If you're unsure, try running these scripts first in a safe environment such as a virtual machine.
<br><br>
> Important: This project is fully open and free for everyone to use. It is not designed for cheating, hacking, or any harmful purposes.  
> The code is shared in good faith for learning, improvement, and > community use.
