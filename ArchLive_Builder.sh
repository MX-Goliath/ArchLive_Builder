#!/bin/bash

######################################################################################################################
source ./credentials.sh
source ./selectindgenv.sh
source ./kernel_select.sh


######################################################################################################################
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

get_copy_option() {
    while true; do
        echo "Select the copy option:"
        echo "1. Copy all files and folders (including hidden ones)"
        echo "2. Copy only non-hidden files and folders"
        echo "3. Copy only hidden files and folders"
        read -p "Enter the number (1/2/3): " option
        case $option in
            1 ) return 1;;
            2 ) return 2;;
            3 ) return 3;;
            * ) echo "Please enter 1, 2, or 3.";;
        esac
    done
}

copy_files() {
    local option=$1
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"

    if [[ $option -eq 1 ]]; then
        shopt -s dotglob
    elif [[ $option -eq 3 ]]; then
        shopt -s dotglob
    else
        shopt -u dotglob
    fi

    for dir in "$HOME"/*/; do
        if [[ "$dir" != "$SCRIPT_DIR/"* ]]; then
            if [[ $option -eq 1 ]]; then
                sudo cp -r "$dir" "archlive/airootfs/etc/skel/"
            elif [[ $option -eq 2 && "${dir##*/}" != .* ]]; then
                sudo cp -r "$dir" "archlive/airootfs/etc/skel/"
            elif [[ $option -eq 3 && "${dir##*/}" == .* ]]; then
                sudo cp -r "$dir" "archlive/airootfs/etc/skel/"
            fi
        fi
    done

    if [[ $option -eq 1 || $option -eq 3 ]]; then
        shopt -u dotglob
    fi
    echo "Copying completed."
}



move_iso_to_releases() {
    local iso_path="$1"
    local releases_dir="releases"
    local iso_name=$(basename "$iso_path")
    local new_path="$releases_dir/$iso_name"
    local counter=1

    mkdir -p "$releases_dir"

    while [ -f "$new_path" ]; do
        new_path="${releases_dir}/${iso_name%.*}_${counter}.${iso_name##*.}"
        ((counter++))
    done

    # Move the file
    sudo mv "$iso_path" "$new_path"
    echo "ISO image moved to: $new_path"
}



######################################################################################################################
command -v mkarchiso >/dev/null 2>&1 || { echo >&2 "mkarchiso is not installed. Installing..."; sudo pacman -S --noconfirm archiso; }
sudo pacman -Sc --noconfirm


if [ -d "archlive" ]; then
    echo "archlive folder found, removing..."
    sudo rm -rf archlive
    echo "archlive folder successfully removed."
else
    echo "archlive folder does not exist."
fi

cp -r /usr/share/archiso/configs/releng/ archlive

if get_yes_no "Do you want to copy folders from the user's home directory to archlive/airootfs/etc/skel/?"; then
    get_copy_option
    option=$?
    copy_files $option
else
    echo "Copying canceled by the user."
fi

# Update packages
> archlive/packages.x86_64
cat packages >> archlive/packages.x86_64

select_kernel

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


select_desltop_env

# Копирование файлов LiveIsoData
if [ -d "LiveIsoData" ]; then
    cp -r LiveIsoData/. archlive/airootfs/etc/skel/
else
    echo "LiveIsoData folder not found, skipping copying."
fi


get_user_credentials
# echo "Username: $username"
# echo "Root password: $root_password"
# echo "User password: $password"

echo "Do you want to add the user $username to sudoers? (y/n)"
read -r add_sudo


cat <<EOF > archlive/airootfs/root/customize_airootfs.sh
#!/bin/bash


echo "root:$root_password" | chpasswd


useradd -m -G wheel -s /bin/bash $username
echo "$username:$password" | chpasswd

EOF

if [ "$add_sudo" = "y" ]; then
    echo "echo \"$username ALL=(ALL) ALL\" >> /etc/sudoers.d/99_wheel" >> archlive/airootfs/root/customize_airootfs.sh
    echo "chmod 440 /etc/sudoers.d/99_wheel" >> archlive/airootfs/root/customize_airootfs.sh
fi

# echo "systemctl enable sddm" >> archlive/airootfs/root/customize_airootfs.sh
if [ -n "$display_manager_service" ]; then
    echo "systemctl enable $display_manager_service" >> archlive/airootfs/root/customize_airootfs.sh
fi
echo "systemctl enable NetworkManager" >> archlive/airootfs/root/customize_airootfs.sh
if [[ "$desktop_env" != "deepin" ]]; then
    echo "systemctl enable bluetooth.service" >> archlive/airootfs/root/customize_airootfs.sh
fi


# chmod +x archlive/airootfs/root/customize_airootfs.sh

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
