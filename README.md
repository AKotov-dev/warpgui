# warpgui
GUI for Cloudflare ™ WARP  
  
+ Automatic registration with the WARP API
+ Automatic check of warp-svc.service status
+ Sent/Received (IN/OUT) connection indicator
+ Automatic checking of WARP updates when the GUI is launched
+ The `F12` key - emergency `endpoint` change; one click - new value (60 options)
  
**Dependencies:** expect nftables zenity p7zip fping curl

Cloudflare ™ (Linux desktop client): https://developers.cloudflare.com/warp-client/get-started/linux/

Since there are no `cloudflare-warp` package for Mageia (the rpm package for CentOS is installed with an error), `warpgui` package already contain `/usr/bin/warp-cli` and `/usr/bin/warp-svc` from the [original Cloudflare ™ packages](https://pkg.cloudflareclient.com/packages/cloudflare-warp). However, starting from `warpgui-v0.7`, the download is carried out automatically from the manufacturer's website.  
![](https://github.com/AKotov-dev/warpgui/blob/main/ScreenShots/warpgui-11.png) ![](https://github.com/AKotov-dev/warpgui/blob/main/ScreenShots/warpgui-12.png)  
Tested in Mageia-8/9.  
  
**Note:** [WARP with firewall](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/firewall/). To check the WARP functionality, temporarily disable `iptables`.
