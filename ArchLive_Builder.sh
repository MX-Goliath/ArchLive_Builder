#!/bin/bash

# Function to get a yes/no response
get_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

# Function to get a password with confirmation
get_password() {
    while true; do
        read -s -p "$1: " password
        echo
        read -s -p "Confirm $1: " password_confirm
        if [ "$password" = "$password_confirm" ]; then
            echo "$password"
            return
        else
            echo "Passwords do not match. Please try again."
        fi
    done
}

# Function to move ISO to the releases folder
move_iso_to_releases() {
    local iso_path="$1"
    local releases_dir="releases"
    local iso_name=$(basename "$iso_path")
    local new_path="$releases_dir/$iso_name"
    local counter=1

    # Create releases folder if it does not exist
    mkdir -p "$releases_dir"

    # Check if a file with the same name already exists
    while [ -f "$new_path" ]; do
        new_path="${releases_dir}/${iso_name%.*}_${counter}.${iso_name##*.}"
        ((counter++))
    done

    # Move the file
    mv "$iso_path" "$new_path"
    echo "ISO image moved to: $new_path"
}

# Install archiso
sudo pacman -S --noconfirm archiso

# Check and remove archlive folder
if [ -d "archlive" ]; then
    echo "archlive folder found, removing..."
    sudo rm -rf archlive
    echo "archlive folder successfully removed."
else
    echo "archlive folder does not exist."
fi

# Copy releng configuration
cp -r /usr/share/archiso/configs/releng/ archlive

# Copy folders from home directory
if get_yes_no "Do you want to copy all folders from the user's home directory, including hidden ones, to archlive/airootfs/etc/skel/?"; then
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"
    shopt -s dotglob
    for dir in "$HOME"/*/; do
        if [[ "$dir" != "$SCRIPT_DIR/"* ]]; then
            cp -r "$dir" "archlive/airootfs/etc/skel/"
        fi
    done
    shopt -u dotglob
    echo "Copying completed."
else
    echo "Copying canceled by the user."
fi

# Update packages
> archlive/packages.x86_64
cat packages >> archlive/packages.x86_64

if get_yes_no "Do you want to add additional packages from the Arch repositories?"; then
    read -p "Enter the package names separated by space: " additional_packages
    echo "$additional_packages" >> archlive/packages.x86_64
fi

# Enable multilib
sed -i 's/^#\[multilib\]/[multilib]/' archlive/pacman.conf
sed -i 's|^#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|' archlive/pacman.conf

# Locale selection
locales_file="locales.txt"
if [ ! -f "$locales_file" ]; then
    echo "$locales_file not found!"
    exit 1
fi

echo "Available locales:"
cat -n "$locales_file"
while true; do
    read -p "Select the locale number: " locale_number
    selected_locale=$(sed -n "${locale_number}p" "$locales_file")
    if [ -n "$selected_locale" ]; then
        echo "LANG=${selected_locale}" > archlive/airootfs/etc/locale.conf
        echo "Locale set to ${selected_locale}"
        break
    else
        echo "Invalid selection, please try again."
    fi
done

# Copy LiveIsoData files
cp -r LiveIsoData/. archlive/airootfs/etc/skel/

# Get user data
root_password=$(get_password "Enter password for root")
echo
read -p "Enter the username: " username
echo
user_password=$(get_password "Enter password for user")
echo

add_sudo=$(get_yes_no "Do you want to add user $username to sudoers?")

# Get the wallpaper path
# while true; do
#     read -p "Enter the full path to the wallpaper image (leave blank for default wallpaper): " wallpaper_path
#     wallpaper_path="${wallpaper_path//\"/}"
#     if [ -z "$wallpaper_path" ] || [ -f "$wallpaper_path" ]; then
#         break
#     else
#         echo "Image file not found. Please check the path and try again."
#     fi
# done

# Configure wallpaper
# if [ -n "$wallpaper_path" ]; then
#     cp "$wallpaper_path" archlive/airootfs/etc/skel/Pictures/
#     wallpaper_filename=$(basename "$wallpaper_path")
#     cat <<EOF > archlive/airootfs/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc
# [Containments][1]
# activityId=
# formfactor=0
# immutability=1
# lastScreen=0
# location=0
# plugin=org.kde.desktopcontainment
# wallpaperplugin=org.kde.image
#
# [Containments][1][Wallpaper][org.kde.image][General]
# Image="file:///home/$username/Pictures/$wallpaper_filename"
# EOF
# fi

# Create customize_airootfs.sh script
cat <<EOF > archlive/airootfs/root/customize_airootfs.sh
#!/bin/bash

echo "root:$root_password" | chpasswd
useradd -m -G wheel -s /bin/bash $username
echo "$username:$user_password" | chpasswd

EOF

if [ "$add_sudo" = "y" ]; then
    echo "echo \"$username ALL=(ALL) ALL\" >> /etc/sudoers.d/99_wheel" >> archlive/airootfs/root/customize_airootfs.sh
    echo "chmod 440 /etc/sudoers.d/99_wheel" >> archlive/airootfs/root/customize_airootfs.sh
fi

echo "systemctl enable sddm" >> archlive/airootfs/root/customize_airootfs.sh
echo "systemctl enable NetworkManager" >> archlive/airootfs/root/customize_airootfs.sh
echo "systemctl enable bluetooth.service" >> archlive/airootfs/root/customize_airootfs.sh

chmod +x archlive/airootfs/root/customize_airootfs.sh

echo "Configuration complete. You can proceed with creating the ISO."

if get_yes_no "Do you want to create the ISO now?"; then
    cd archlive
    sudo mkarchiso -v .
    cd ..

    # Find the created ISO image
    iso_path=$(find archlive/out -name "*.iso" -type f -print -quit)

    if [ -n "$iso_path" ]; then
        echo "ISO successfully created: $iso_path"
        move_iso_to_releases "$iso_path"
    else
        echo "Failed to find the created ISO image."
    fi
else
    echo "ISO creation postponed. You can create it later by running 'sudo mkarchiso -v .' in the archlive folder."
fi
