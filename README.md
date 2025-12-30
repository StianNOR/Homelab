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
gpg --verify signatures/font_nerd_hack.sh.sig font_nerd_hack.sh
```


Expected output:  

`Good signature from "StianNOR stiannor@duck.com"`  



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


| Before | After |
| :---: | :---: |
| ![Before Image](<Standard Terminal.png>) | ![After Image](<ZSH StianNOR install.png>) |

