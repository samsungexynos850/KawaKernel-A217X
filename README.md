# KawaKernel Source Code for SM-A217M/F
**Based on A217MUBSBDWK1**

## About
KawaKernel is a performance oriented kernel tuned for pushing as much performance as possible from the device.
The project was initially lead by **Doz Naka** but **RiskyGUY22** now leads it.

## Features

**I recommend using [KernelManager](https://github.com/DozNaka/KawaKernel-A217X/releases/latest) to change kernel settings**

**Compiler**
* Proton Clang compiler (Clang 13)
* Polly optimization flags
* Exynos 3830 optimization flags

**Performance**
* NET: Default TCP Congestion Control: BBR + fq_codel qdisc
* NET: Enabled ECN negotiation by default
* NET: Improved network performance by using TCP_NODELAY
* MEM: Backported linux-5.17 lib/LZ4
* MEM: ZRam enabled with LZ4 as default compression algorithm
* MEM: KSM enabled (turned off by default)
* CPU: Overclocked to 2210 Mhz and underclocked to 130 Mhz
* CPU: Default CPUFREQ Governor: SCHEDUTIL
* GPU: Overclocked to 1196 Mhz and underclocked to 100 Mhz
* GPU: High speed frequency is 754 Mhz by default
* GPU: Adaptive power policy (default)

**Battery savings**
* Implemented Capacity Aware Superset Scheduler
* Implemented Boeffla wakelock blocker v1.1.0
* Implemented Powersuspend v2.0 driver
* Dynamic Fsync
* Kernelspace battery saver mode
* Samsung state notifier

**Misc**
* Disabled SELinux audit logs
* Disabled Samsung Knox
* Disabled some of DEBUGFS
* Disabled some log spam
* Kernel support for Wireguard vpn
* Mass storage support (DriveDroid, etc)
* Prerooted with KernelSU
* Implemented SchedTune Assist
* CPU and GPU voltage control
* Kernel upstream

*And many more*

## Download
* [KawaKernel A12](https://github.com/samsungexynos850/KawaKernel-A217X/releases/latest)
* [KawaKernel A11 (deprecated)](https://github.com/DozNaka/KawaKernel-A217X/releases/tag/KawaKernel-v1.3.1)

## Installation
* Follow instructions and install [TWRP](https://github.com/DozNaka/android_device_samsung_a21s/releases)
* Press install button then find "KawaKernel-A217X.zip"
* Proceed to flash
* Boot

## KernelSU App
* Download the [KernelSU APK](https://github.com/tiann/KernelSU/releases/download/v0.9.2/KernelSU_v0.9.2_11682-release.apk)
* This app can be used to install modules and give apps root access

## Credits
**xxmustafacooTR**: KernelManager, voltage control implementation, overclock implementation.
**Physwizz**: Initial project and overclock
And those who are on the contribution list included on reference commits

**Join our [Telegram](https://t.me/+NkphbKPxiB8xZjY9) group to get updates about our device**
