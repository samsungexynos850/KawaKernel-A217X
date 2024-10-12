#!/bin/bash

export PATH=/home/thomas/toolchains/clang-r353983c/clang-r353983c/bin/:/home/thomas/toolchains/gcc/bin/:$PATH
export PLATFORM_VERSION=12
export ANDROID_MAJOR_VERSION=s
export ARCH=arm64

mkdir out
make ARCH=arm64 kawa_defconfig CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-androidkernel- CC=clang O=out -j64
make ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-androidkernel- CC=clang O=out -j64
