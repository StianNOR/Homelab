# Simplify and Beautify Your Linux Terminal Experience ✨

> [!TIP]  
> Having issues? Please open an issue here: [https://github.com/StianNOR/Homelab/issues](https://github.com/StianNOR/Homelab/issues)  
> Or join the community on Discord: [https://discord.gg/eHEHCzGCAE](https://discord.gg/eHEHCzGCAE)

---

## Supported Package Managers ✅

| Package Manager | Distros |
|-----------------|-------------------------------------------|
| **APT**         | Debian, Ubuntu, Linux Mint, Pop!_OS, Deepin, etc |
| **DNF**         | Fedora, CentOS 8+, RHEL 8+, Rocky Linux, AlmaLinux, etc |
| **YUM**         | CentOS 7, older RHEL versions, Oracle Linux, etc |
| **Pacman**      | Arch Linux, Manjaro, EndeavourOS, Artix Linux, etc |
| **Zypper**      | openSUSE, SUSE Linux Enterprise, etc |

---

## Clone, Verify, and Install Homelab ✅

### Script Authenticity ⚠️

All scripts in this repository are digitally signed with my Keybase-managed PGP key.  
This ensures the scripts you download are authentic and haven’t been tampered with.

### Clone and Prepare
```
cd ~ # Go to your home directory (check with 'pwd')
git clone https://github.com/StianNOR/Homelab.git
cd Homelab
sudo chmod +x *.sh
```

### Import My Public Key

PGP fingerprint:  
`52FE58C1C8BDA54D68E09C143E305BD749B795A3`

```
curl https://keybase.io/sarttech7/pgp_keys.asc | gpg --import

```


### Verify Scripts


```
gpg --verify signatures/setup_zsh.sh.asc setup_zsh.sh
gpg --verify signatures/up.sh.asc up.sh
gpg --verify signatures/portainerup.sh.asc portainerup.sh
gpg --verify signatures/portainer_docker_uninstall.sh.asc portainer_docker_uninstall.sh
gpg --verify signatures/uninstall_zsh_setup.sh.asc uninstall_zsh_setup.sh
gpg --verify signatures/font_nerd_hack.sh.asc font_nerd_hack.sh
```


Expected output:  

Good signature from "StianNOR stiannor@duck.com"



> [!IMPORTANT]  
> You may see this warning:  
> `WARNING: This key is not certified with a trusted signature!`  
>
> This simply means GPG does not yet fully trust the key.  
> To mark it as trusted locally:  
> ```
> gpg --edit-key 3E305BD749B795A3
> trust
> # Select option 5 (ultimate trust)
> y
> quit
> ```  
> Only assign ultimate trust to keys you have personally verified.

---

## Installation Steps

1. **Install the Nerd Hack Font**  

```
./font_nerd_hack.sh
```

Configure the font in your system settings and terminal preferences.  
A reboot is usually required.

2. **Run the Main Setup Script**  
```
./setup_zsh.sh
```

After installation, reboot or log out/in to apply the changes.

---

## Portainer and Docker Installation ✅

If you want to install Docker and Portainer, simply run `pup` in the terminal and follow the prompts.  

- When asked to reboot or relog, do so.  
- If prompted, also run:  
```
newgrp docker
```

- Successful setup will display a confirmation message in the terminal.  

Later, you can also update Portainer by running:



---

## Uninstall Options 😦

**Remove Portainer and Docker:**  
```
./portainer_docker_uninstall.sh
```


**Uninstall the Zsh Setup (restart terminal afterward):**  
```
./uninstall_zsh_setup.sh
```


---

## Helpful Shortcuts 🤓

**Show active Zsh aliases:**  
```
ali
```


**Directory listing shortcuts:**  

| Command | Expands to       | Description                              |
|---------|-----------------|------------------------------------------|
| `ls`    | `ls`            | List files and directories               |
| `ll`    | `ls -l`         | Detailed long format                     |
| `la`    | `ls -a` / `ls -la` | Show all files, including hidden ones |
| `sls`   | `ls -ls`        | Show listings with file sizes and details |

---

## Author

Best regards,  
**StianNOR**  
(Known as *sarttech7* on Keybase)  
[https://keybase.io/sarttech7](https://keybase.io/sarttech7)

---

## Disclaimer ⚠️

This script is provided *as-is* for supported Linux distributions.  
While tested on common setups, it may not work for all configurations.  

- Always back up important data before running these scripts.  
- The author accepts no responsibility for data loss or damage.  
- If unsure, test first in a virtual machine or safe environment.  
- This project is fully open and free to use, intended only for educational and community purposes — never for harmful activities.  











OLD

## Simplify and beautify your Linux terminal experience with this handy script. :sparkles:
<br><br>

> [!TIP]
> Any issue please add here: https://github.com/StianNOR/Homelab/issues  
> Or join my Discord: https://discord.gg/eHEHCzGCAE

<br><br>

The script supports Linux distros using these package managers: ✅
<br><br>
| Package Manager | Distro |
|---------|----------------|
| APT     | Debian, Ubuntu, LinuxMint, PopOS, Deepin, etc  |
| DNF     | Fedora, CentOS 8+, RHEL 8+, Rocky Linux, AlmaLinux, etc  |
| YUM     | CentOS 7, older RHEL versions, Oracle Linux, etc  |
| Pacman  | Arch Linux, Manjaro, EndeavourOS, Artix Linux, etc      |
| Zypper  | openSUSE, SUSE, etc     |

<br><br>
<br><br>

### Clone Verify and Install Homelab. ✅

<br><br>

### Verifying Script Authenticity ⚠️

<br><br>

Each script in this repository is digitally signed with my special security key managed on Keybase.  
This means you can check that the scripts really come from me and haven't been changed by anyone else.

<br><br>

Clone and Prepare for Verification ⚠️

```
cd ~ # Go to home directory, Can also check dir whit command: pwd
git clone https://github.com/StianNOR/Homelab.git
cd Homelab
sudo chmod +x *.sh
```

<br><br>

Import My Public Key ✅

PGP public key fingerprint:  
`52FE58C1C8BDA54D68E09C143E305BD749B795A3`

To verify any script before running: ✅

Import my GPG public key:
```
curl https://keybase.io/sarttech7/pgp_keys.asc | gpg --import
```
This imports my current PGP public key with fingerprint: ✅
```
52FE 58C1 C8BD A54D 68E0 9C14 3E30 5BD7 49B7 95A3
```
Verifying Scripts: ✅
```
gpg --verify signatures/setup_zsh.sh.asc setup_zsh.sh
gpg --verify signatures/up.sh.asc up.sh
gpg --verify signatures/portainerup.sh.asc portainerup.sh
gpg --verify signatures/portainer_docker_uninstall.sh.asc portainer_docker_uninstall.sh
gpg --verify signatures/uninstall_zsh_setup.sh.asc uninstall_zsh_setup.sh
gpg --verify signatures/font_nerd_hack.sh.asc font_nerd_hack.sh
```
You should see an output like: ✅
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
```
`Then type:`    
`trust`    
`Select option 5 (ultimate trust)`  
`y`  
`quit`  

<br><br>

> [!NOTE]
> Only mark keys you personally verify as ultimately trusted. ⚠️

> Why Trust Matters  
> The trust model in GPG prevents blindly trusting keys or signatures.  
> My Keybase profile provides an additional identity assurance layer,  
> but users must assign trust locally to verify authenticity fully.

<br><br>

After verifying you can go on whit installing: ✅

First install the fonts:
```
./font_nerd_hack.sh
```
Would also recommend to double check that fonts are set in system settings and in your terminal.
reboot is usaly needed.
<br><br>
<br><br>
Then next up is the main script:

```
./setup_zsh.sh
```
Please reboot or relog to make changes. ✅

<br><br>
### 4. Install Portainer and Docker: ✅ (You dont need to install Docker and Portainer if not using it.)
<br><br>
Now you should just type `pup` in terminal. Then follow prompts.
When prompted to reboot or relog do so, and also do `newgrp docker` if prompted.
Portainer and docker is ready if you get this msg:
<br><br>
<img width="661" height="46" alt="image" src="https://github.com/user-attachments/assets/41a5297a-fe00-41cb-acb7-67e1a98acbb5" />
<br><br>
### If you installed Portainer and Docker you can in future use command `pup` to also update portainer.

<br><br>

### Uninstall (Uninstall scripts are located in /home/$USER/Homelab.) 😦
To remove Portainer and Docker, run: 😭
```
./portainer_docker_uninstall.sh
```

<br><br>

To uninstall the Zsh setup (restart terminal after uninstall): 😭
```
./uninstall_zsh_setup.sh
```

<br><br>

> [!TIP]
> Helpful advice for doing things better or more easily.
<br><br>
To show currently used zsh aliases: 🤓
```
ali
```

<br><br>

Directories info shortcuts: 📝
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
