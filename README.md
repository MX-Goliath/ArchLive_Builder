# ArchLive_Builder
This project is a tool for creating custom Arch Linux Live images. The user can include the necessary packages and settings in the image, as well as add their files and configurations, which will be automatically applied upon boot.

# Arch Linux Live Image Builder

## Project Description

This project is a script for automatically creating Arch Linux Live images. The script allows you to build a minimal image with the necessary packages and settings for various scenarios, such as system recovery, diagnostics, or installing Arch Linux on new devices.

## Project Structure

- `ArchLive_Builder_En.sh`: The main script for creating the Arch Linux Live image.
- `packages`: A file containing the base list of packages to be included in the image.
- `LiveIsoData`: A folder where users can place their files, which will then be available in the `home` directory of the created image. You can also place configuration files here, such as KDE environment settings, which will be automatically applied when the image is booted.

## Installation and Usage

1. Clone the repository or download the project files.
2. Run the `ArchLive_Builder_En.sh` script. During the script execution, you will be prompted to add additional packages that you want to include in the image.
3. Add any necessary files and configurations to the `LiveIsoData` folder.
4. Wait for the process to complete and retrieve the ready-to-use Arch Linux Live image.

```bash
./ArchLive_Builder_En.sh
```

## Requirements

- Installed Arch Linux.
- root privileges to run the script.

## Support

If you have any questions or suggestions for improving the project, you can create an issue in the repository or contact the developers directly.

