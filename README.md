# warpgui
GUI for Cloudflare ™ WARP  
![](https://github.com/AKotov-dev/warpgui/blob/main/ScreenShots/warpgui-11.png) ![](https://github.com/AKotov-dev/warpgui/blob/main/ScreenShots/warpgui-12.png)  
+ Automatic registration with the WARP API
+ Automatic check of warp-svc.service status
+ Sent/Received (IN/OUT) connection indicator
+ The `F2` key - installation of cloudflare-warp
+ The `F11` key - resetting WARP settings to default
+ The `F12` key - emergency `endpoint` change; one click - new value (60 options)
  
**Dependencies:** gtk2 xterm libcap-utils
  
The `cloudflare-warp` package is now updated as part of a general system update from the Cloudflare ™ WARP [repository](https://pkg.cloudflareclient.com/#rhel) or manually via the command: `dnf install -y libcap-utils && dnf install -y cloudflare-warp`.  
  
Manual installation of the repository and the `cloudflare-warp` package for Mageia (if necessary):
```
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | tee /etc/yum.repos.d/cloudflare-warp.repo && dnf update && dnf install -y libcap-utils && dnf install -y cloudflare-warp
```
Tested in Mageia-9. [WARP with firewall](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/firewall/): to check the WARP functionality, temporarily disable `iptables`.
