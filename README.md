# ArchLive_Builder
This project is a tool for creating custom Arch Linux Live images. The user can include the necessary packages and settings in the image, as well as add their files and configurations, which will be automatically applied upon boot.

# Arch Linux Live Image Builder

## Project Description

This project is a script for automatically creating Arch Linux Live images. The script allows you to build a minimal image with the necessary packages and settings for various scenarios, such as system recovery, diagnostics, or installing Arch Linux on new devices.

## Project Structure

- `ArchLive_Builder_En.sh`: The main script for creating the Arch Linux Live image.
- `packages`: A file containing the base list of packages to be included in the image.
- `LiveIsoData`: A folder where users can place their files, which will then be available in the `home` directory of the created image. You can also place configuration files here, such as KDE environment settings, which will be automatically applied when the image is booted.
- `locales.txt`: File with a list of locales.
- `credentials.sh` - function for setting root user password and regular user login and password.
- `selectindgenv.sh` - function to select graphical environment.

## Installation and Usage

1. Clone the repository or download the project files.
2. Run the `ArchLive_Builder_En.sh` script. During the script execution, you will be prompted to add additional packages that you want to include in the image.
3. Add any necessary files and configurations to the `LiveIsoData` folder. Place your local files and configuration files in this folder. In the final ISO image, they will be located in the same directory as they are here. That is, configuration files should be placed in the .conf/... folder, and so on.
5. Wait for the process to complete and retrieve the ready-to-use Arch Linux Live image.
```bash
chmod +x credentials.sh selectindgenv.sh ArchLive_Builder.sh
```

```bash
./ArchLive_Builder.sh
```
## Note
**! It is highly recommended not to interrupt the process of directly building the ISO image, as this may result in files that are not deleted under sudo** 


## Requirements

- Installed Arch Linux.
- root privileges to run the script.

## Future Plans:

- [ ] Add support for selecting different desktop environments.
- [ ] Improve the command-line interface for better user interaction.
- [x] Clearing previous builds.
- [ ] Creating regular and engineering releases.
- [ ] Adding packages from AUR.
- [ ] Ability to automatically copy all or some user files.
- [ ] Normal GUI (Is it needed???).
- [ ] Adding an installer for a full system transfer from the ISO to the PC.
- [x] Adding the option to select locales

If you have any questions or suggestions for improving the project, you can create an issue in the repository or contact me via email.

## Version history
### V0.2

**Added:**
- Clean-up of previous builds
- Automatic copying of all files
- Option to select locales
- ISO file is now automatically moved to the releases folder

**Deleted:**
- Ability to select wallpaper files

The user is now prompted before creating the image.
Added locales file

### V0.3
**Added:**
- Added the ability to select a graphical environment from: KDE Plasma, GNOME, XFCE(testing), Deepin(testing), Hyperland(testing)
- Some functions have been moved to separate files to improve code readability and simplify work
- For now, sddm has been selected as the default manager(In future releases, different managers will be added for different graphical environments)
