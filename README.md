# my arch setup

my personal scripts and notes for a minimal and clean arch linux installation.

## about this repo

this repository holds the automation script i use for setting up a fresh arch linux system. the goal is to quickly build a clean environment using kde plasma.

it's built for my own use, but hosted publicly on github so i can easily pull the script from anywhere.

## automated setup

to run the script, do the following:

```
sudo pacman -Syu --needed git --noconfirm
git clone https://github.com/residentevilfreak/arch-setup
cd arch-setup
chmod +x setup.sh
./setup.sh
```

or the shorter way

```sh
curl -sL sihr.me/setup.sh | bash
```

## my configuration checklist

after the script is done, the following options to be configured:

### behavior
- configure spectacle's settings.
- change the show desktop widget's function to minimize all windows.
- add the music presence application to autostart.

### hardware (pc)
- disable cursor acceleration.
- configure power management.

### hardware (laptop)
- invert the touchpad scroll direction for 'natural scrolling'.
- reduce the touchpad's scroll speed for better control.

### appearance
- set the global display scale to 90%.
- edit the application menu to hide unwanted entries.
- cuztomize the cursor.
- set a user profile picture.
- customize taskbar applications.
- configure the system tray to show only the icons i need.
- customize the digital clock.
- apply a global dark theme.
- set new wallpapers.
- disable the startup splash screen.
- customize the panel.
- apply an sddm theme.
