# arch-setup

my personal scripts and notes for a minimal and clean arch linux installation. 

this repository holds the script i use for setting up a fresh arch linux system. the goal is to quickly build a clean environment. it's built for my own use, but hosted publicly on github so i can easily pull the script.

## getting started

the setup script can be ran using one of two methods below.

> it is generally not recommended to run scripts directly from the internet via curl without first reviewing them. since this is my own script, i don't mind running it this way.

---

### method 1: one-liner via curl

this method downloads and runs the script in a single command.

* for zsh:
    ```bash
    curl -sL sihr.me/zsh.sh | bash
    ```

* for fish:
    ```bash
    curl -sL sihr.me/fish.sh | bash
    ```
---

### method 2: clone the repository

this method allows the scripts to be inspected before running them.

1.  **install git and clone the repository:**

    ```bash
    sudo pacman -Syu --needed git --noconfirm
    git clone https://github.com/residentevilfreak/arch-setup
    cd arch-setup
    ```
    

2. **run the scripts:**

* for zsh:
    ```bash
    chmod +x zsh.sh
    ./zsh.sh
    ```

* for fish:
    ```bash
    chmod +x fish.sh
    ./fish.sh
    ```

## post script configuration checklist

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
