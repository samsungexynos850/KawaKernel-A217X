# KawaKernel Source Code for SM-A217M/F
**Based on A217MUBU9DVF6**

## About
KawaKernel is a performance oriented kernel tuned for pushing as much performance as possible from the device.

## Features

**Performance**
* [x] NET: Default TCP Congestion Control: BBR + fq_codel qdisc
* [x] NET: Enabled ECN negotiation by default
* [x] NET: Improved network proformance by using TCP_NODELAY
* [ ] MEM: Backported linux-5.17 lib/LZ4 for ZRam performance
* [x] MEM: ZRam enabled with ZSTD as default compression algorithm
* [ ] MEM: Enabled block i/o tracing for IOReps Prefetching
* [x] CPU: Overclocked to 2210 Mhz and underclocked to 130 Mhz by Physwizz
* [x] CPU: Default CPUFREQ Governor: SCHEDUTIL
* [x] GPU: Overclocked to 1196 Mhz
* [ ] GPU: High speed frequency is 754 Mhz by default
* [ ] GPU: Controls for voltage, thermal etc
* [ ] GPU: Adaptive power policy (default)
* [ ] RANDOM: Implemented SRANDOM and it is enabled by default

**Battery savings**
* [ ] Implemented Boeffla wakelock blocker v1.1.0
* [ ] Implemented Powersuspend v2.0 driver
* [ ] Dymanic Fsync
* [ ] Kernelspace battery saver mode
* [ ] Samsung state notifier

**Misc**
* [x] Disabled SELinux audit logs
* [x] Disabled Samsung Knox
* [x] Disabled some of DEBUGFS
* [ ] Kernel support for Wireguard vpn