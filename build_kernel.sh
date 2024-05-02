#!/bin/bash
# Build script for KawaKernel - Made by @RiskyGU22

# Set Project and Version name
PROJECT_NAME="Kawa Kernel"
VERSION=v3.0

# Define variables for packaging names
KAWA_ENFORCING=KawaKernel-A217X_$VERSION.zip
KAWA_PERMISSIVE=KawaKernel-A217X-Permissive_$VERSION.zip
KAWA_TWRP=KawaKernel-A217X-TWRP.zip

# Export variables used to compile
export ARCH=arm64
export PLATFORM_VERSION=12
export ANDROID_MAJOR_VERSION=s

# Add toolchain location to path
export PATH=/home/$USER/toolchains/proton-clang/bin/:$PATH
export LLVM=1
export LLVM_IAS=1
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-

# Export Variables related to Kawa's packaging
export DEFCONFIG=kawa_defconfig
export DEFCONFIG_LOC=$(pwd)/arch/$ARCH/configs
export KAWA_LOC=$(pwd)/Kawa
export KAWA_BOOT=$(pwd)/out/arch/$ARCH/boot
export KAWA_DTS=$(pwd)/out/arch/$ARCH/boot/dts
export ANYKERNEL=$(pwd)/Kawa/AnyKernel3
export PACKAGING=$(pwd)/Kawa/packaging

# Get date and time
DATE=$(date +"%m-%d-%y")
BUILD_START=$(date +"%s")

################### Executable functions #######################
CLEAN_PACKAGES()
{
	# Check for the existence of an out directory
	if [ ! -e "out" ]; then
		mkdir out
	fi

	# Clean previous builds
	rm -rf $KAWA_LOC/AnyKernel3/Image
	rm -rf $KAWA_LOC/packaging/*.zip
	rm -rf $KAWA_BOOT/Image
	rm -rf $DEFCONFIG_LOC/.tmp_defconfig

}

CLEAN_SOURCE()
{
	# Option to Clean source
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

DETECT_TOOLCHAIN()
{
	# Download toolchain
	if [ ! -e "$HOME/toolchains/proton-clang" ]; then
    	echo "Toolchain NOT detected: Downloading now..."
    	sudo git clone --depth=1 https://github.com/kdrag0n/proton-clang ~/toolchains/proton-clang/ > /dev/null 2>&1
    	echo "Toolchain was Successfully found!"
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
	make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w .tmp_defconfig
	make -j64 -C $(pwd) O=$(pwd)/out KCFLAGS=-w

	# Check if kernel Image was created
	if [ ! -e $KAWA_BOOT/Image ]; then
	echo "Failed to compile Kernel!"
	echo "Abort"
	exit 0;
	fi

}


AnyKernel3()
{
	# Build packaging with AnyKernel3
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
	cp -f $KAWA_BOOT/Image $ANYKERNEL

	# Build packaging
	cd $ANYKERNEL
	zip -r $ZIPNAME *
	chmod 0777 $ZIPNAME
	mv $ZIPNAME $PACKAGING
	# Change back into kernel source directory
	cd ../../

	if [ -e "$ANYKERNEL/Image" ]; then
		rm -rf $ANYKERNEL/Image
	fi
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
	AnyKernel3
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
