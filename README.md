# KawaKernel Source Code for SM-A217M/F
**Based on A217MUBS8CVB2**

## Features
* Compiled with Proton Clang 13.0.0
* Enabled Polly optimizations
* Upstreamed with the latest kernel sources from google
* Kernel support for Wireguard vpn
* Default TCP Congestion Control: BBR + fq_codel qdisc
* Enabled ECN negotiation by default 
* Enabled Kernel Same-page Merging
* Implemented Boeffla wakelock blocker
* Implemented Powersuspend v1.8 driver
* Disabled CONFIG_AUDIT
* ZRam enabled with LZ4 as default compression algorithm
* CPU: Overclocked to 2210 Mhz and underclocked to 130 Mhz by Physwizz
* GPU: Overclocked to 1001 Mhz

## Plans
- [ ] ~~Permissive kernel variant~~ (not needed)
- [ ] Overclock GPU to 1146+ Mhz

# Warning
![Warning](http://www.clker.com/cliparts/H/Z/0/R/f/S/warning-icon-hi.png)

**While this kernel is somewhat stable, I should warn you that anything that occurs to your device, I will not be responsible for it. You are making the choice to install this kernel onto your device.**

**I am not a developer so do not expect me to fix complicated bugs, I do accept pull requests if it is helpful.**
