# Lineage Kernel For A21s/A12
**Based on A217MUBSBDWK1**

## About
My goal in this project is to make a stable kernel for the whole of the A21s and
the A12 including all binary's and versions with numerous performance boosts and,
edits to the kernel config. I intend to eventually mainline this kernel, so look forward to that :D!

 
## Features

**Compiler**
* GCC v4.9 Toolchain, with clang

**General**
* SELinux enforcing
* KernelSU
* Can be built with latest AOSP
* Halium compliant config
* Improved MTP and USB connections
* 4.19.275 Upstream merged in
* Post Market OS compliant config
* Underclocked and overclocked some CPU cores.
* GPU Overclocked

## Download
* [Lineage A12](https://github.com/Samsung-Galaxy-A21s/android_kernel_samsung_a21s/releases)

## Installation
* This guide assumes you already have TWRP/custom recovery installed!
* Boot into recovery mode by pressing, Volume Up + Power Button
* Go to, Wipe -> format data -> yes, then reboot back to recovery
* Go to Terminal and type: $ multidisabler  :then reboot to recovery
* Press adb sideload option
* Run the command $ adb sideload "LineageKernel-A21s.zip" using [SDK Tools](https://dl.google.com/android/repository/platform-tools-latest-windows.zip)
* Then reboot to system and enjoy Lineage Kernel!!

## Common Issues
Sometimes if you don't format data a custom kernel/boot image will cause a boot loop and in TWRP you will notice an error like:
' Android Rescue Party Triggered ' this can be fixed by formating data and rebooting to system.

## A21s Telegram Channel

For all updates on the A21s join this channel: https://t.me/+k5gU822DXnkwODk1
If any bugs are found with my kernel please let me know here ^^^
