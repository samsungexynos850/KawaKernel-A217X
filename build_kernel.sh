#!/bin/bash

clear
export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export ARCH=arm64

export LLVM=1
export PATH="$HOME/toolchains/proton-clang/bin:$PATH"
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export CLANG_TRIPLE=$HOME/toolchains/gcc-linaro/bin/aarch64-linux-gnu-
export DEFCONFIG_LOC=$(pwd)/arch/$ARCH/configs

rm -rf $DEFCONFIG_LOC/.tmp_defconfig

read -p "Clean source? [N] (Y/N): " clean_confirm
if [[ $clean_confirm == [yY] || $clean_confirm == [yY][eE][sS] ]]; then
    echo "Cleaning source ..."
    make clean && make mrproper
    rm -rf $(pwd)/out
else
    echo "Source will not be cleaned for this build."
fi
clear

read -p $'Choose device:\x0a1) SM-A217M\x0a2) SM-A217F\x0aSelection: ' device_selection
if [[ $device_selection == 1 ]]; then
    clear
    echo "Selected SM-A217M"
    cat $DEFCONFIG_LOC/physwizz_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
    cat $DEFCONFIG_LOC/a217m_defconfig >> $DEFCONFIG_LOC/.tmp_defconfig
elif [[ $device_selection == 2 ]]; then
    clear
    echo "Selected SM-A217F"
    cat $DEFCONFIG_LOC/physwizz_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
else
    clear
    echo $'You have not selected a valid device!\x0aQuit'
fi

make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y .tmp_defconfig
make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y