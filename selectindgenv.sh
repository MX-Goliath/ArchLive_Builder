# selectindgenv.sh

select_desltop_env() {
# Выбор окружения рабочего стола
echo "Select the desktop environment:"
options=("KDE Plasma" "GNOME" "XFCE" "Deepin" "Hyperland")
select opt in "${options[@]}"; do
    case $opt in
        "KDE Plasma")
            desktop_env="kde"
            packages=(
                "plasma-meta"
                "konsole"
                "kwrite"
                "dolphin"
                "ark"
                "plasma-workspace"
                "egl-wayland"
            )
            break
            ;;
        "GNOME")
            desktop_env="gnome"
            packages=(
                "gnome"
                "gnome-tweaks"
            )
            break
            ;;
        "XFCE")
            desktop_env="xfce"
            packages=(
                "xfce4"
                "xfce4-goodies"
                "pavucontrol"
                "gvfs"
                "xarchiver"
            )
            break
            ;;
        "Deepin")
            desktop_env="deepin"
            packages=(
                "deepin"
                "deepin-terminal"
                "deepin-editor"
            )
            break
            ;;
        "Hyperland")
            desktop_env="hyperland"
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
