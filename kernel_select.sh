# kernel_select.sh

select_kernel() {
    kernels=("linux" "linux-lts" "linux-zen" "linux-hardened")

    echo "Select a kernel from the following options:"

    for i in "${!kernels[@]}"; do
        echo "$((i+1)). ${kernels[$i]}"
    done

    read -p "Enter the number of the selected kernel: " choice

    if [[ $choice -ge 1 && $choice -le ${#kernels[@]} ]]; then
        kernel="${kernels[$((choice-1))]}"
        echo "$kernel" >> archlive/packages.x86_64
    else
        echo "Incorrect selection. Please run the script again and select the correct number."
    fi
}


