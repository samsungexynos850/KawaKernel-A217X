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

read -p "Clean source? [N] (Y/N): " clean_confirm
if [[ $clean_confirm == [yY] || $clean_confirm == [yY][eE][sS] ]]; then
    echo "Cleaning source ..."
    make clean && make mrproper
    rm -rf $(pwd)/out
else
    echo "Source will not be cleaned for this build."
fi
clear

make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y physwizz_defconfig
make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y