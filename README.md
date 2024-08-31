# ArchLive_Builder

This project is a tool for creating custom Arch Linux Live images. Users can include the necessary packages and configurations in the image, as well as add their files and settings, which will be automatically applied upon boot. The project is designed for comprehensive testing of builds before installing them on actual hardware, eliminating the need for system reinstallation. Future plans include adding an installer, allowing users to fully install the system from the ISO live image (Planned for release 1.0).

# Arch Linux Live Image Creator

## Project Description

This project is a script for automatically creating Arch Linux Live images. The script allows users to create a minimal image with the necessary packages and settings for various scenarios such as system recovery, diagnostics, or installing Arch Linux on new devices.

## Project Structure

- `ArchLive_Builder_En.sh`: The main script for creating the Arch Linux Live image.
- `packages`: A file containing a basic list of packages to be included in the image.
- `LiveIsoData`: A folder where users can place their files, which will then be available in the `home` directory of the created image. Configuration files, such as KDE environment settings, can also be placed here and will be automatically applied upon boot.
- `locales.txt`: A file containing a list of locales.
- `credentials.sh`: A function to set the root user password, and the username and password of a regular user.
- `selectindgenv.sh`: A function to select the graphical environment.

## Installation and Usage

1. Clone the repository or download the project files.
2. Run the `ArchLive_Builder_En.sh` script. During script execution, you will be prompted to add additional packages you wish to include in the image.
3. Add the necessary files and configurations to the `LiveIsoData` folder. Place your local files and configuration files in this folder. In the final ISO image, they will be located in the same directory structure. Configuration files should be placed in the `.conf/...` folder, etc.
4. Wait for the process to complete and obtain a ready-to-use Arch Linux Live image.

```bash
chmod +x credentials.sh selectindgenv.sh ArchLive_Builder.sh
```

```bash
./ArchLive_Builder.sh
```

## Note
**! It is strongly recommended not to interrupt the ISO creation process, as this may result in files that are not deleted when using sudo.**

## Requirements

- An installed Arch Linux system.
- Root privileges to execute the script.

## Future Plans:

- [x] Add support for selecting different graphical environments.
- [ ] Improve the command-line interface for better user interaction.
- [x] Cleanup of previous builds.
- [ ] Create regular and engineering releases.
- [ ] Add support for AUR packages.
- [x] Automatic copying of all or some user files.
- [ ] Implement a proper GUI (is this necessary???).
- [ ] Add an installer for fully transferring the system from ISO to a PC.
- [x] Add an option to select locales.
- [ ] Resize editing.

If you have any questions or suggestions for improving the project, you can create an issue in the repository or contact me via email.

## Version History
### V0.2

**Added:**
- Cleanup of previous builds
- Automatic copying of all files
- Locale selection option
- ISO file is now automatically moved to the releases folder

**Removed:**
- Wallpaper file selection option

Users are now prompted before creating the image.
Locale file added.

### V0.3
**Added:**
- Added the ability to select a graphical environment from: KDE Plasma, GNOME, XFCE (testing), Deepin (testing), Hyperland (testing)
- Some functions were moved to separate files for better code readability and ease of use
- Currently, SDDM is selected as the manager (different managers will be added for different graphical environments in future releases)

### V0.4
**Added:**
- Managers for desktop environments (currently SDDM for GNOME)
- Kernel selection from linux, linux-lts, linux-zen, and linux-hardened
- Option to copy user files from the home directory: hidden files only, visible files only, or all files.

**Fixed:**
- Creation of a multi-terabyte folder due to pacman. To address this, pacman cache cleanup was added before installation.
- Further splitting of the code into separate files.
