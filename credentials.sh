# credentials.sh

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
