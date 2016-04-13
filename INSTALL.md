Europe project run on Intel NUC mini PC. Follow this instruction to prepare
NUC machine for our application.

# Ubuntu installation on NUC

* Download image ubuntu-14.04.4-desktop-amd64 on Ubuntu site.
* Put empty USB disk into computer and run UNetbootin application. Choose 
  downloaded image and prepare USB disk (this step take ~10 minutes)
* Put USB into NUC, turn on and select Boot options according to
  http://cdn.arstechnica.net/wp-content/uploads/2014/01/BIOS.png
  - Secure boot: Disabled
  - Secure boot mode: Standard
  - Platform Key (PKpub): Not Installed
  - Key Exchange Key (KEK): Installed
  - Signature Database (db): Installed
  - Blacklisted Signature Database (dbx): Installed
* Connect NUC to Enthernet and boot from USB
* Install Ubuntu:
  - Grub: Install Ubuntu
  - Language: English
  - [x] Download updates while installing
    [x] Install 3rd party software
  - Erase disk and install Ubuntu
    (partition #1 sda EFIboot, partition #2 sda etx4, partition #4 sda swap)
  - Timezone: Prague
  - Keyboard: English (US)
  - Your name: europe
    Computer name: europe
    Username: europe
    [x] Log in automatically
* After installation process, reboot Ubuntu and eject USB drive
* Launch Software updater and update system
* Install SSH server via terminal: `sudo apt-get install openssh-server`
* Set System Settings:
  - Brightness & Lock
    - Turn screen off when inactive for: Never
    - Lock: OFF
    - [ ] Require my password when waking from suspend
  - Software & Updates
    - Updates tab
      - Automatically check for updates: Never
* Note IP address of machine: `ifconfig eth0` and follow with Ansible described 
  bellow

Further information about Ubuntu installation on NUC: 
http://arstechnica.com/gadgets/2014/02/linux-on-the-nuc-using-ubuntu-mint-fedora-and-the-steamos-beta/

# Run Ansible playboook

Ansible is tool for easy system provisioning and application deployment.
We use it for installing all necessary SW on Ubuntu, configuration and 
deployment of application.

Prerequisities: You will need Ansible version 1.7.1

Steps:

* Put you public SSH `id_rsa.pub` key into `/home/europe/.ssh/authorized_keys` 
  on NUC machine (beware, directory `/home/europe/.ssh` must be set to `0700` 
  mode)
* Repeat it for `/home/root` folder (yes, we are now allowing remote root
  access to machine)
* Go into [`ansible/`](ansible) directory, copy file `hosts.example` to `hosts`
  and replace string `<IP_ADDRESS_OF_YOUR_MACHINE>` to your NUC IP (see last 
  step in [Ubuntu installation on NUC](#ubuntu-installation-on-nuc) section)
* Run command: `ansible-playbook bootstrap.yml -i hosts`

When playbook finish, logout from Unity desktop environment. You will see login
screen with input field for password. Next to it on right side is white circle.
Click on it and change it to LXDE.

# Notes

## Switch back to Unity environment

* open terminal with CTRL+ALT+T shortcut
* run command `lxpanel --profile LXDE` -- you will see bar on bottom of the 
  screen with logout button
* logout
* on login screen change environment back to Unity (click on white circle)

## Switch to text terminal

Press CTRL+ALT+F1 shortcut to go away from GUI to text terminal.
