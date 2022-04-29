#!/bin/bash

clear
export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export ARCH=arm64

export LLVM=1
export PATH="$HOME/toolchains/proton-clang/bin:$PATH"
export CROSS_COMPILE=aarch64-linux-gnu-
export DEFCONFIG_LOC=$(pwd)/arch/$ARCH/configs
export DTB_LOC=$(pwd)/out/arch/$ARCH/boot/dts
export TOOLS_LOC=$(pwd)/scripts/tools/bin
export KAWA_LOC=$(pwd)/Kawa

# Reguardless of clean build or not, remove these files
rm -rf $DEFCONFIG_LOC/.tmp_defconfig
rm -rf $KAWA_LOC/boot.img
rm -rf $KAWA_LOC/AIK-Linux/split_img/boot.img-dtb
rm -rf $KAWA_LOC/AIK-Linux/split_img/boot.img-kernel
rm -rf $KAWA_LOC/Flashable/KawaKernel-A217X.zip
rm -rf $DTB_LOC/../Image

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
    cat $DEFCONFIG_LOC/kawa_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
    cat $DEFCONFIG_LOC/a217m_defconfig >> $DEFCONFIG_LOC/.tmp_defconfig
elif [[ $device_selection == 2 ]]; then
    clear
    echo "Selected SM-A217F"
    cat $DEFCONFIG_LOC/kawa_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
else
    clear
    echo $'You have not selected a valid device!\x0aQuit'
fi

make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y .tmp_defconfig
make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y
if [ ! -e $DTB_LOC/../Image ]; then
echo "Failed to compile Image!"
echo "Abort"
exit 0;
fi

# Build DTB/DTBO img
echo 'Building DTB/DTBO Image ...'
$TOOLS_LOC/mkdtboimg.py cfg_create $DTB_LOC/dtb.img --dtb-dir $DTB_LOC/exynos $KAWA_LOC/dtb.cfg
$TOOLS_LOC/mkdtboimg.py cfg_create $DTB_LOC/dtbo.img --dtb-dir $DTB_LOC/samsung/a21s $KAWA_LOC/dtbo.cfg
echo 'Done!'

# TODO: Make this more presentable
# Copy files to AIK SPLIT_IMG folder
cp -r $DTB_LOC/dtb.img $KAWA_LOC/AIK-Linux/split_img/boot.img-dtb
cp -r $DTB_LOC/../Image $KAWA_LOC/AIK-Linux/split_img/boot.img-kernel
# Build boot.img
$KAWA_LOC/AIK-Linux/repackimg.sh
cp -r $KAWA_LOC/AIK-Linux/image-new.img $KAWA_LOC/Flashable/boot.img
echo 'Check Kawa/Flashable for boot.img'

# Create flashable zip
cd $KAWA_LOC/Flashable
zip -r KawaKernel-A217X.zip *
cd ../../
echo 'Check Kawa/Flashable for KawaKernel-A217X.zip'