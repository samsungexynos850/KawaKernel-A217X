#!/bin/bash
# Build script for KawaKernel

export PLATFORM_VERSION=12
export ANDROID_MAJOR_VERSION=s
export ARCH=arm64

export LLVM=1
export PATH="$HOME/toolchains/azure-clang/bin:$PATH"
export CROSS_COMPILE=aarch64-linux-gnu-

export DEFCONFIG_LOC=$(pwd)/arch/$ARCH/configs
export DTB_LOC=$(pwd)/out/arch/$ARCH/boot/dts
export KAWA_LOC=$(pwd)/Kawa

# Reguardless of clean build or not, remove these files
rm -rf $DEFCONFIG_LOC/.tmp_defconfig
rm -rf $KAWA_LOC/boot.img
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

read -p $'Choose variant:\x0a1) Android (Standard)\x0a2) Android (Permissive)\x0a3) Recovery\x0aSelection: ' device_selection
if [[ $device_selection == 1 ]]; then
    echo "Selected Android (Standard)"
    cat $DEFCONFIG_LOC/kawa_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
elif [[ $device_selection == 2 ]]; then
    echo "Selected Android (Permissive)"
    cat $DEFCONFIG_LOC/kawa_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
    cat $DEFCONFIG_LOC/permissive_defconfig >> $DEFCONFIG_LOC/.tmp_defconfig
elif [[ $device_selection == 3 ]]; then
    echo "Selected Recovery"
    cat $DEFCONFIG_LOC/twrp_slim_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
else
    echo $'You have not selected a valid variant!\x0aQuit'
    exit 0;
fi

echo 'Building Kernel ...'
make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y .tmp_defconfig
make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y
if [ ! -e $DTB_LOC/../Image ]; then
echo "Failed to compile Kernel!"
echo "Abort"
exit 0;
fi

# Build DTB/DTBO img
echo 'Building DTB/DTBO Image ...'
$KAWA_LOC/mkdtimg cfg_create $DTB_LOC/dtb.img $KAWA_LOC/dtb.cfg -d $DTB_LOC/exynos
$KAWA_LOC/mkdtimg cfg_create $DTB_LOC/dtbo.img $KAWA_LOC/dtbo.cfg -d $DTB_LOC/samsung/a21s
echo 'Done!'

# Build boot.img
$KAWA_LOC/AIK-Linux/unpackimg.sh
###
cp -r $DTB_LOC/dtb.img $KAWA_LOC/AIK-Linux/split_img/boot.img-dtb
cp -r $DTB_LOC/../Image $KAWA_LOC/AIK-Linux/split_img/boot.img-kernel
###
$KAWA_LOC/AIK-Linux/repackimg.sh
cp -r $KAWA_LOC/AIK-Linux/image-new.img $KAWA_LOC/Flashable/boot.img
$KAWA_LOC/AIK-Linux/cleanup.sh
echo 'Check Kawa/Flashable for boot.img'

# Create flashable zip
cd $KAWA_LOC/Flashable
zip -r KawaKernel-A217X.zip *
cd ../../
echo 'Check Kawa/Flashable for KawaKernel-A217X.zip'
