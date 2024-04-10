#!/bin/bash
# Build script for KawaKernel

# Set Project and Zip names
PROJECT_NAME="Kawa Kernel"
KAWA_ENFORCING=KawaKernel-A217X.zip
KAWA_PERMISSIVE=KawaKernel-A217X-Permissive.zip
KAWA_TWRP=KawaKernel-A217X-TWRP.zip

# Export variables
export ARCH=arm64
export PLATFORM_VERSION=12
export ANDROID_MAJOR_VERSION=s
export LLVM=1

export DEFCONFIG=kawa_defconfig
export DEFCONFIG_LOC=$(pwd)/arch/$ARCH/configs
export KAWA_LOC=$(pwd)/Kawa
export KAWA_BOOT=$(pwd)/out/arch/$ARCH/boot
export KAWA_DTS=$(pwd)/out/arch/$ARCH/boot/dts
export PACKAGING=$(pwd)/Kawa/packaging
export TARGET_KERNEL_CLANG_COMPILE=true
export CLANG_VERSION="clang-r450784d"

# Get date and time
DATE=$(date +"%m-%d-%y")
BUILD_START=$(date +"%s")

################### Executable functions #######################
CLEAN_PACKAGES()
{
	if [ ! -e "out" ]; then
		mkdir out
	fi

	# Clean previous builds
	rm -rf $KAWA_LOC/packaging/boot.img
	rm -rf $KAWA_LOC/packaging/*.zip
	rm -rf $KAWA_BOOT/Image
	rm -rf $DEFCONFIG_LOC/.tmp_defconfig

}

CLEAN_SOURCE()
{
  	read -p "Clean source? [Y] (Y/N): " clean_confirm
  	if [[ $clean_confirm == [yY] || $clean_confirm == [yY][eE][sS] ]]; then
    	echo "Cleaning source ..."
    	make clean && make mrproper
    	rm -rf $(pwd)/out
  	else
    	echo "Source will not be cleaned..."
  	fi
}

UPDATE_DEPS()
{
  	if hostnamectl | grep -q 'Ubuntu'; then
    	echo "Ubuntu machine detected: missing dependencies will be installed..."
    	sudo apt update > /dev/null 2>&1
    	sudo apt upgrade -y > /dev/null 2>&1
    	sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison python3 python-is-python3 -y > /dev/null 2>&1
    	echo "Dependencies Installed Successfully!"
  	else
    	echo "Ubuntu machine NOT detected - *DEPENDENCIES will NOT be installed*"
  	fi
}

WIREGUARD_INTEGRATION()
{
	if [ -n "$CONFIG_WIREGUARD" ]; then
		cat "source \"net/wireguard/Kconfig\"" >> net/Kconfig
		cat "$(shell cd \"$(srctree)\" && ./scripts/fetch-latest-wireguard.sh)" >> scripts/Kbuild.include
	fi
}

DETECT_TOOLCHAIN()
{
	# Check if CLANG_DIR exists, if not try alternative paths
	if [ -d "$HOME/toolchains/clang/$CLANG_VERSION" ]; then
    	CLANG_DIR="$HOME/toolchains/clang/$CLANG_VERSION"
	elif [ ! -d "$HOME/toolchains/clang/$CLANG_VERSION" ]; then
		sudo git clone --depth=1 -b android-13.0.0_r75 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 ~/toolchains/clang/
		CLANG_DIR="$HOME/toolchains/clang/$CLANG_VERSION"
	else
    	echo -e "${RED}Could not find the specified clang directory.${DEFAULT}"
    	exit 1
	fi

}

DEVICE_SELECTION()
{
	read -p $'Choose variant:\x0a1) Android (Standard)\x0a2) Android (Permissive)\x0a3) Recovery\x0aSelection: ' device_selection
	if [[ $device_selection == 1 ]]; then
		echo "Selected Android (Standard)"
		cat $DEFCONFIG_LOC/kawa_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
		export ZIPNAME=$KAWA_ENFORCING
	elif [[ $device_selection == 2 ]]; then
		echo "Selected Android (Permissive)"
		cat $DEFCONFIG_LOC/kawa_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
		cat $DEFCONFIG_LOC/permissive_defconfig >> $DEFCONFIG_LOC/.tmp_defconfig
		export ZIPNAME=$KAWA_PERMISSIVE
	elif [[ $device_selection == 3 ]]; then
		echo "Selected Recovery"
		cat $DEFCONFIG_LOC/twrp_slim_defconfig > $DEFCONFIG_LOC/.tmp_defconfig
		export ZIPNAME=$KAWA_TWRP
	else
		echo $'You have not selected a valid variant!\x0aQuit'
		exit 0;
	fi
}

BUILD_KERNEL()
{
	echo "*****************************************************"
	echo "           Building $PROJECT_NAME           "
	echo "Building Kernel ..."

	PATH="$CLANG_DIR/bin:${PATH}"
	export LD=/home/thomas/a21s/LineageOS/prebuilts/clang/host/linux-x86/clang-r450784d/bin/ld.lld
	export ld=/home/thomas/a21s/LineageOS/prebuilts/clang/host/linux-x86/clang-r450784d/bin/ld.lld

	make O=out ARCH=arm64 .tmp_defconfig
	make -j$(nproc --all) O=out ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- LD=ld.lld LLVM=1 LLVM_IAS=1 Image || exit

	# Check if kernel Image was created
	if [ ! -e $KAWA_BOOT/Image ]; then
	echo "Failed to compile Kernel!"
	echo "Abort"
	exit 0;
	fi

}


AIK-Linux()
{
	# Building boot image with AIK-Linux
	if [ -e "$KAWA_BOOT/Image" ]; then

	echo -e "*****************************************************"
	echo -e "*                                                   *"
	echo -e "*       Building flashable boot image...            *"
	echo -e "*                                                   *"
	echo -e "*****************************************************"

    # Build device trees
    $KAWA_LOC/mkdtimg cfg_create $KAWA_DTS/dtb.img $KAWA_LOC/dtb.cfg -d $KAWA_DTS/exynos
    $KAWA_LOC/mkdtimg cfg_create $KAWA_DTS/dtbo.img $KAWA_LOC/dtbo.cfg -d $KAWA_DTS/samsung/a21s

	# Build bootable image
	$KAWA_LOC/AIK-Linux/unpackimg.sh
    cp -f $KAWA_BOOT/Image $KAWA_LOC/AIK-Linux/split_img/boot.img-kernel
    cp -f $KAWA_DTS/dtb.img $KAWA_LOC/AIK-Linux/split_img/boot.img-dtb
	$KAWA_LOC/AIK-Linux/repackimg.sh
	cp -f $KAWA_LOC/AIK-Linux/image-new.img $PACKAGING/boot.img
	$KAWA_LOC/AIK-Linux/cleanup.sh


	# Build packaging
	cd $PACKAGING
	zip -r $ZIPNAME *
	chmod 0777 $ZIPNAME
	# Change back into kernel source directory
	cd ../../
	fi
}

DISPLAY_ELAPSED_TIME()
{
	# Find out how much time build has taken
	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))

	BUILD_SUCCESS=$?
	if [ $BUILD_SUCCESS != 0 ]
		then
			echo " Error: Build failed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds $reset"
			exit
	fi

	echo -e " Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds $reset"
}


MAIN()
{
  	UPDATE_DEPS
  	DETECT_TOOLCHAIN
  	CLEAN_PACKAGES
  	CLEAN_SOURCE
	WIREGUARD_INTEGRATION
  	DEVICE_SELECTION
	echo "***************************************************** "
	echo "                                                     "
	echo "        Starting compilation of Kawa kernel          "
	echo "                                                     "
	echo "        Defconfig = $DEFCONFIG                       "
	echo "                                                     "
	echo "                                                     "
	echo "                                                     "
	BUILD_KERNEL
	echo " "
	AIK-Linux
	echo " "
	DISPLAY_ELAPSED_TIME
	echo " "
	echo "**********************************************************************"
	echo "*                                                                    *"
	echo "*                         build finished                             *"
	echo "*           Check Kawa/packaging for a flashable zip                 *"
	echo "*                                                                    *"
	echo "**********************************************************************"
}


#################################################################

# Call the function which runs everything
MAIN
