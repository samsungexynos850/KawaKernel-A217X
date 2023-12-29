# KawaKernel Source Code for SM-A217M/F
**Based on A217MUBSBDWK1**

## About
KawaKernel is a performance oriented kernel tuned for pushing as much performance as possible from the device.

## Features

**I recommend using ThunderTweaks to change kernel settings**

**Compiler**
* Azure Clang compiler (Clang 15)
* Polly optimization flags
* Exynos 3830 optimization flags

**Performance**
* NET: Default TCP Congestion Control: BBR + fq_codel qdisc
* NET: Enabled ECN negotiation by default
* NET: Improved network proformance by using TCP_NODELAY
* MEM: Backported linux-5.17 lib/LZ4
* MEM: ZRam enabled with LZ4 as default compression algorithm
* MEM: KSM enabled (turned off by default)
* CPU: Overclocked to 2210 Mhz and underclocked to 130 Mhz by Physwizz
* CPU: Default CPUFREQ Governor: SCHEDUTIL
* GPU: Overclocked to 1196 Mhz
* GPU: High speed frequency is 754 Mhz by default
* GPU: Adaptive power policy (default)
* SCHED: Implemented SchedTune Assist

**Battery savings**
* Implemented Boeffla wakelock blocker v1.1.0
* Implemented Powersuspend v2.0 driver
* Dynamic Fsync
* Kernelspace battery saver mode
* Samsung state notifier

**Misc**
* Disabled SELinux audit logs
* Disabled Samsung Knox
* Disabled some of DEBUGFS
* Kernel support for Wireguard vpn
* Mass storage support (DriveDroid, etc)
* Prerooted with KernelSU

## Download
* [KawaKernel A12](https://github.com/DozNaka/KawaKernel-A217X/releases/latest)
* [KawaKernel A11 (EOL)](https://github.com/DozNaka/KawaKernel-A217X/releases/tag/KawaKernel-v1.3.1)

## Installation
* Follow instructions and install [TWRP](https://github.com/DozNaka/android_device_samsung_a21s/releases)
* Press install button then find "KawaKernel-A217X.zip"
* Proceed to flash
* Boot

**Join our [Telegram](https://t.me/+NkphbKPxiB8xZjY9) group to get updates about our device**
