# arch-setup

my personal scripts and notes for a minimal and clean arch linux installation. 

this repository holds the script i use for setting up a fresh arch linux system. the goal is to quickly build a clean environment. it's built for my own use, but hosted publicly on github so i can easily pull the script.

## getting started

the setup script can be ran using one of two methods below.

> it is generally not recommended to run scripts directly from the internet via curl without first reviewing them. since this is my own script, i don't mind running it this way.

### method 1

run the setup script directly:

```bash
bash <(curl -sL sihr.me/setup.sh)
```

### method 2

clone the repository and run the script:

```bash
git clone https://github.com/residentevilfreak/arch-setup
cd arch-setup
sudo bash setup.sh
```

## post-script configuration

### behavior
- configure spectacle's screenshot settings
- change the show desktop widget to minimize all windows
- add the music presence app to autostart

### hardware (pc)
- disable cursor acceleration
- configure power management

### hardware (laptop)
- invert the touchpad scroll direction for natural scrolling
- reduce the touchpad's scroll speed for better control

### appearance
- set the global display scale to 90%
- edit the application menu to hide unwanted entries
- customize the cursor
- set a user profile picture
- customize taskbar applications
- configure the system tray to show only needed icons
- customize the digital clock
- apply a global dark theme
- set new wallpapers
- disable the startup splash screen
- customize the panel
- apply an sddm theme
