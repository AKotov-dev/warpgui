# warpgui
GUI for Cloudflare ™ WARP  
  
+ Automatic registration with the WARP API
+ Automatic check of warp-svc.service status
+ Sent/Received (IN/OUT) connection indicator
+ Automatic checking of WARP updates when the GUI is launched
  
**Dependencies:** expect nftables zenity p7zip fping curl

Cloudflare ™ (Linux desktop client): https://developers.cloudflare.com/warp-client/get-started/linux/

Since there are no `cloudflare-warp` package for Mageia (the rpm package for CentOS is installed with an error), `warpgui` package already contain `/usr/bin/warp-cli` and `/usr/bin/warp-svc` from the [original Cloudflare ™ packages](https://pkg.cloudflareclient.com/packages/cloudflare-warp).  
![](https://github.com/AKotov-dev/warpgui/blob/main/ScreenShots/warpgui-11.png) ![](https://github.com/AKotov-dev/warpgui/blob/main/ScreenShots/warpgui-12.png)  
  
![](https://github.com/AKotov-dev/warpgui/blob/main/ScreenShots/warpgui-13.png)
Tested in Mageia-8/9 (without the cloudflare-warp package) and LUbuntu-22.04 (portable, without auto update). In LUbuntu `warpgui` can work without installation, but with the original `cloudflare-warp` package installed.
