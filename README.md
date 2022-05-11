# KawaKernel Source Code for SM-A217M/F
**Based on A217MUBS8CVB2**

## Features
**Compiler**
* Compiled with Proton Clang 13.0.0
* O3_WITH_OFAST_SUB_OPTIONS + Polly optimizations

**Performance**
* NET: Default TCP Congestion Control: BBR + fq_codel qdisc
* NET: Enabled ECN negotiation by default 
* NET: Improved network proformance by using TCP_NODELAY
* MEM: Enabled Kernel Same-page Merging (off by default)
* MEM: Backported linux-5.17 lib/LZ4 for ZRam performance
* MEM: ZRam enabled with LZ4 as default compression algorithm
* MEM: Enabled block i/o tracing for IOReps Prefetching
* MEM: Implemented Simple Low Memory Killer (GSI variant only)
* CPU: Overclocked to 2210 Mhz and underclocked to 130 Mhz by Physwizz
* CPU: Implemented SchedTune Assist v3
* CPU: Default CPUFREQ Governor: SCHEDUTIL
* GPU: Overclocked to 1196 Mhz
* GPU: High speed frequency is 754 Mhz by default
* GPU: Controls for voltage, thermal etc
* GPU: Adaptive power policy (default)
* GPU: Updated drivers to R37P0
* RANDOM: Implemented SRANDOM and it is enabled by default

**Battery savings**
* Implemented Boeffla wakelock blocker v1.1.0
* Implemented Powersuspend v2.0 driver
* Dymanic Fsync
* Kernelspace battery saver mode
* Samsung state notifier

**Misc**
* Boots Android 12 GSIs
* Disabled SELinux audit logs
* Disabled Samsung Knox
* Keeping up-to-date with [linux-stable](https://github.com/gregkh/linux/tree/linux-4.19.y)
* Kernel support for Wireguard vpn

## NOTICE
**KawaKernel aims to be a performance kernel so its settings are leaning towards more performance out of your device. Therefore you shall not complain about battery drainage.**

**If you want KawaKernel to be battery savings oriented then follow these steps.**
- Switch CPU governor to energy_step or conservative
- Switch GPU power policy to course_demand
- Underclock CPU
- Underclock GPU
- Turn off KSM if enabled (expect small RAM usage increase)
With these settings combined with the battery saving features implemented on this kernel, you should receive better battery savings than on stock kernel.

## Building KawaKernel
**Requirements**
- A linux machine
- base-devel (arch) or build-essential (debian) packages
- [proton-clang](https://github.com/physwizz/Toolchains-for-Eureka)
- The kernel source obviously

**Steps**
- Rename Toolchains-for-Eureka to proton-clang
- Place proton-clang folder in $HOME/toolchains/
- cd into the kernel source
- Run ./build_kernel.sh
- Preferredly answer yes to clean build

## Installing KawaKernel from compiled source
**Steps**
- Check $SRC/Kawa/Flashable/KawaKernel-A217X.zip file when compiling is done
- Flash the zip with a custom recovery

# Warning
![Warning](http://www.clker.com/cliparts/H/Z/0/R/f/S/warning-icon-hi.png)

**While this kernel is somewhat stable, I should warn you that anything that occurs to your device, I will not be responsible for it. You are making the choice to install this kernel onto your device.**

**I am not a developer so do not expect me to fix complicated bugs, I do accept pull requests if it is helpful.**