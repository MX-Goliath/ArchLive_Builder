# selectindgenv.sh

select_desltop_env() {
echo "Select the desktop environment:"
options=("KDE Plasma" "GNOME" "XFCE" "Deepin" "Hyperland")
desktop_env=""
display_manager_service=""

select opt in "${options[@]}"; do
    case $opt in
        "KDE Plasma")
            desktop_env="kde"
            display_manager_service="sddm"
            packages=(
                "plasma-meta"
                "konsole"
                "kwrite"
                "dolphin"
                "ark"
                "plasma-workspace"
                "egl-wayland"
                "sddm"
            )
            break
            ;;
        "GNOME")
            desktop_env="gnome"
            display_manager_service="gdm"
            packages=(
                "gnome"
                "gnome-tweaks"
                "gdm"
            )
            break
            ;;
        "XFCE")
            desktop_env="xfce"
            display_manager_service="lightdm"
            packages=(
                "xfce4"
                "xfce4-goodies"
                "pavucontrol"
                "gvfs"
                "xarchiver"
                "lightdm"
                "lightdm-gtk-greeter"
            )
            break
            ;;
        "Deepin")
            desktop_env="deepin"
            display_manager_service="lightdm"
            packages=(
                "deepin"
                "deepin-terminal"
                "deepin-editor"
            )
            break
            ;;
        "Hyperland")
            desktop_env="hyprland"
            display_manager_service=""
            packages=(
                "hyprland"
                "dunst"
                "kitty"
                "dolphin"
                "wofi"
                "xdg-desktop-portal-hyprland"
                "qt5-wayland"
                "qt6-wayland"
                "polkit-kde-agent"
                "grim"
                "slurp"
            )
            break
            ;;
        *) echo "Wrong choice $REPLY";;
    esac
done
if [ -n "$desktop_env" ]; then
    for pkg in "${packages[@]}"; do
        echo "$pkg" >> archlive/packages.x86_64
    done
fi
}
