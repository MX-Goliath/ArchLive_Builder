#!/bin/bash

# Install archiso
sudo pacman -S --noconfirm archiso

# Copy the releng configuration to a new directory archlive
cp -r /usr/share/archiso/configs/releng/ archlive

# Remove all packages from archlive/packages.x86_64 and add packages from the packages file
> archlive/packages.x86_64  # Clear the file
cat packages >> archlive/packages.x86_64  # Add packages from the packages file

# Prompt the user to add packages from the Arch repositories
echo "Do you want to add additional packages from the Arch repositories? (y/n)"
read -r add_packages

if [ "$add_packages" = "y" ]; then
    echo "Enter the package names separated by spaces:"
    read -r additional_packages
    echo "$additional_packages" >> archlive/packages.x86_64
fi

# Uncomment lines in pacman.conf to enable multilib
sed -i 's/^#\[multilib\]/[multilib]/' archlive/pacman.conf
sed -i 's|^#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|' archlive/pacman.conf


# Create the skel directory in airootfs/etc
mkdir -p archlive/airootfs/etc/skel/.config
mkdir -p archlive/airootfs/etc/skel/Pictures

# Copy all files from the LiveIsoData folder to archlive/airootfs/etc/skel
cp -r LiveIsoData/. archlive/airootfs/etc/skel/

# Function to prompt for a username and password with confirmation
get_user_credentials() {
    while true; do
        read -s -p "Enter root password: " root_password
        echo
        read -s -p "Confirm root password: " root_password_confirm
        echo
        if [ "$root_password" = "$root_password_confirm" ]; then
            break
        else
            echo "Root passwords do not match. Please try again."
        fi
    done

    read -p "Enter username: " username
    while true; do
        read -s -p "Enter user password: " password
        echo
        read -s -p "Confirm user password: " password_confirm
        echo
        if [ "$password" = "$password_confirm" ]; then
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done
}

# Function to prompt for the wallpaper path and check if it exists
get_wallpaper_path() {
    while true; do
        read -p "Enter the full path to the wallpaper image (leave blank for default wallpaper): " wallpaper_path
        wallpaper_path="${wallpaper_path//\"/}"  # Remove quotes if present

        if [ -z "$wallpaper_path" ]; then
            break
        elif [ -f "$wallpaper_path" ]; then
            break
        else
            echo "Image file not found. Please check the path and try again."
        fi
    done
}

# Prompt for user credentials
get_user_credentials

# Ask the user if they want to add the user to sudo
echo "Do you want to add the user $username to sudoers? (y/n)"
read -r add_sudo

# Prompt for the wallpaper path
get_wallpaper_path

# If a wallpaper path is provided, copy the wallpaper and configure it
if [ -n "$wallpaper_path" ]; then
    # Copy the image to the /archlive/airootfs/etc/skel/Pictures/ directory
    cp "$wallpaper_path" archlive/airootfs/etc/skel/Pictures/

    # Get the file name from the path
    wallpaper_filename=$(basename "$wallpaper_path")

    # Create the plasma-org.kde.plasma.desktop-appletsrc file
    cat <<EOF > archlive/airootfs/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc
[Containments][1]
activityId=
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.desktopcontainment
wallpaperplugin=org.kde.image

[Containments][1][Wallpaper][org.kde.image][General]
Image="file:///home/$username/Pictures/$wallpaper_filename"
EOF
fi

# Create the customize_airootfs.sh script
cat <<EOF > archlive/airootfs/root/customize_airootfs.sh
#!/bin/bash

# Set the superuser password
echo "root:$root_password" | chpasswd

# Create a new user
useradd -m -G wheel -s /bin/bash $username
echo "$username:$password" | chpasswd

EOF

# Add the user to sudoers if the user agreed
if [ "$add_sudo" = "y" ]; then
cat <<EOF >> archlive/airootfs/root/customize_airootfs.sh

# Allow the user to use sudo
echo "$username ALL=(ALL) ALL" >> /etc/sudoers.d/99_wheel
chmod 440 /etc/sudoers.d/99_wheel

EOF
fi

# Enable SDDM
echo "systemctl enable sddm" >> archlive/airootfs/root/customize_airootfs.sh
echo "systemctl enable NetworkManager" >> archlive/airootfs/root/customize_airootfs.sh
echo "systemctl enable bluetooth.service" >> archlive/airootfs/root/customize_airootfs.sh

# Set the necessary permissions for the script
chmod +x archlive/airootfs/root/customize_airootfs.sh

echo "Configuration complete. You can proceed with creating the ISO."

cd archlive
sudo mkarchiso -v .
cd ..
