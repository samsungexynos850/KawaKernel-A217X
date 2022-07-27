# KawaKernel Source Code for SM-A217M/F
**Based on A217MUBU9DVF6**

## About
KawaKernel is a performance oriented kernel tuned for pushing as much performance as possible from the device.

## Features

**I recommend using ThunderTweaks to change kernel settings**

**Performance**
* [x] NET: Default TCP Congestion Control: BBR + fq_codel qdisc
* [x] NET: Enabled ECN negotiation by default
* [x] NET: Improved network proformance by using TCP_NODELAY
* [x] MEM: Backported linux-5.17 lib/LZ4
* [x] MEM: ZRam enabled with ZSTD as default compression algorithm
* [x] MEM: KSM enabled (turned off by default)
* [x] CPU: Overclocked to 2210 Mhz and underclocked to 130 Mhz by Physwizz
* [x] CPU: Default CPUFREQ Governor: SCHEDUTIL
* [x] GPU: Overclocked to 1196 Mhz
* [x] GPU: High speed frequency is 754 Mhz by default
* [x] GPU: Adaptive power policy (default)
* [x] RANDOM: Implemented SRANDOM and it is enabled by default
* [x] SCHED: Implemented SchedTune Assist

**Battery savings**
* [x] Implemented Boeffla wakelock blocker v1.1.0
* [x] Implemented Powersuspend v2.0 driver
* [x] Dymanic Fsync
* [x] Kernelspace battery saver mode
* [x] Samsung state notifier

**Misc**
* [x] Disabled SELinux audit logs
* [x] Disabled Samsung Knox
* [x] Disabled some of DEBUGFS
* [x] Kernel support for Wireguard vpn
* [x] DriveDroid Support
* [x] Prerooted with Magisk