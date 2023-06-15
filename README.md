# warpgui
GUI for Cloudflare ™ WARP  
    
+ Automatic registration with the WARP API
+ Automatic check of warp-svc.service status
+ Sent/Received (IN/OUT) connection indicator
+ The `F11` key - resetting WARP settings to default
+ The `F12` key - emergency `endpoint` change; one click - new value (60 options)
  
**Dependencies:** [cloudflare-warp](https://pkg.cloudflareclient.com/#rhel) gtk2

Package `cloudflare-warp` is now installed manually from [Cloudflare ™ WARP repository](https://pkg.cloudflareclient.com/#rhel)  
Cloudflare ™ (Linux desktop client): https://developers.cloudflare.com/warp-client/get-started/linux/  

![](https://github.com/AKotov-dev/warpgui/blob/main/ScreenShots/warpgui-11.png) ![](https://github.com/AKotov-dev/warpgui/blob/main/ScreenShots/warpgui-12.png)  
**Note:** Tested in Mageia-9. [WARP with firewall](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/firewall/): to check the WARP functionality, temporarily disable `iptables`.
