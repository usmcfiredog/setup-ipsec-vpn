﻿## Configure IPsec/L2TP VPN Clients

*Read this in other languages: [English](clients.md), [简体中文](clients-zh.md).*

*To connect using IPsec/XAuth mode, see: [Configure IPsec/XAuth VPN Clients](clients-xauth.md)*

After <a href="https://github.com/hwdsl2/setup-ipsec-vpn" target="_blank">setting up your own VPN server</a>, follow these steps to configure your devices. IPsec/L2TP is natively supported by Android, iOS, OS X, and Windows. There is no additional software to install. Setup should only take a few minutes. In case you are unable to connect, first check to make sure the VPN credentials were entered correctly.

---
* Platforms
  * [Windows](#windows)
  * [OS X](#os-x)
  * [Android](#android)
  * [iOS](#ios)
  * [Chromebook](#chromebook)

### Windows ###
1. Click on the Start Menu and go to the Control Panel.
1. Go to the **Network and Internet** section.
1. Click **Network and Sharing Center**.
1. Click **Set up a new connection or network**.
1. Select **Connect to a workplace** and click **Next**.
1. Click **Use my Internet connection (VPN)**.
1. Enter `Your VPN Server IP` in the **Internet address** field.
1. Enter anything you like in the **Destination name** field.
1. Check the **Don't connect now; just set it up so I can connect later** checkbox.
1. Click **Next**.
1. Enter `Your VPN Username` in the **User name** field.
1. Enter `Your VPN Password` in the **Password** field.
1. Check the **Remember this password** checkbox.
1. Click **Connect**, then click the **Close** button.
1. Return to the Control Panel's **Network and Internet** section and click on the **Connect to a network** option.
1. Right-click on the new VPN connection and choose **Properties**.
1. Click the **Options** tab and uncheck **Include Windows logon domain**.
1. Click the **Security** tab and select **Layer 2 Tunneling Protocol with IPsec (L2TP/IPSec)** from the **Type of VPN** drop-down menu. Under "Allow these protocols", select the `CHAP` checkbox, and de-select `MS-CHAP v2`.
1. Click the **Advanced settings** button.
1. Select **Use preshared key for authentication** and enter `Your VPN IPsec PSK` for the **Key**.
1. Click **OK** to close the **Advanced settings**.
1. Click **OK** to save the VPN connection details.

To connect to the VPN, simply right-click on the wireless/network icon in your system tray, select the new VPN connection, and click **Connect**. You can verify that your traffic is being routed properly by <a href="https://encrypted.google.com/search?q=my+ip" target="_blank">looking up your IP address on Google</a>. It should say "Your public IP address is `Your VPN Server IP`".

**Note:** A <a href="https://documentation.meraki.com/MX-Z/Client_VPN/Troubleshooting_Client_VPN#Windows_Error_809" target="_blank">one-time registry change</a> is required if the VPN server and/or client is behind NAT (e.g. home router). Please refer to the linked page, or run the following from an <a href="http://windows.microsoft.com/en-us/windows/command-prompt-faq#1TC=windows-7" target="_blank">elevated command prompt</a>. You must reboot your computer when done.
- For Windows Vista and newer
  ```console
  REG ADD HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f
  ```

- For Windows XP only
  ```console
  REG ADD HKLM\SYSTEM\CurrentControlSet\Services\IPSec /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f
  ```

### OS X ###
1. Open System Preferences and go to the Network section.
1. Click the **+** button in the lower-left corner of the window.
1. Select **VPN** from the **Interface** drop-down menu.
1. Select **L2TP over IPSec** from the **VPN Type** drop-down menu.
1. Enter anything you like for the **Service Name**.
1. Click **Create**.
1. Enter `Your VPN Server IP` for the **Server Address**.
1. Enter `Your VPN Username` for the **Account Name**.
1. Click the **Authentication Settings** button.
1. In the **User Authentication** section, select the **Password** radio button and enter `Your VPN Password` as its value.
1. In the **Machine Authentication** section, select the **Shared Secret** radio button and enter `Your VPN IPsec PSK` as its value.
1. Click **OK**.
1. Check the **Show VPN status in menu bar** checkbox.
1. Click the **Advanced** button and make sure the **Send all traffic over VPN connection** checkbox is selected.
1. Click the **TCP/IP** tab, and make sure **Link-local only** is selected in the **Configure IPv6** section.
1. Click **OK** to close the Advanced settings, and then click **Apply** to save the VPN connection information.

You can connect to the VPN using the VPN icon in the menu bar, or by selecting the VPN in the Network section of System Preferences and choosing **Connect**. You can verify that your traffic is being routed properly by <a href="https://encrypted.google.com/search?q=my+ip" target="_blank">looking up your IP address on Google</a>. It should say "Your public IP address is `Your VPN Server IP`".

### Android ###
1. Launch the **Settings** application.
1. Tap **More...** in the **Wireless & Networks** section.
1. Tap **VPN**.
1. Tap **Add VPN Profile** or the **+** icon at top-right of screen.
1. Enter anything you like in the **Name** field.
1. Select **L2TP/IPSec PSK** in the **Type** drop-down menu.
1. Enter `Your VPN Server IP` in the **Server address** field.
1. Enter `Your VPN IPsec PSK` in the **IPSec pre-shared key** field.
1. Tap **Save**.
1. Tap the new VPN connection.
1. Enter `Your VPN Username` in the **Username** field.
1. Enter `Your VPN Password` in the **Password** field.
1. Check the **Save account information** checkbox.
1. Tap **Connect**.

Note for Android 6 (Marshmallow) users: On the VPN server, edit `/etc/ipsec.conf` and append `,aes256-sha2_256` to both `ike=` and `phase2alg=` lines. Then add a new line `sha2-truncbug=yes` under section `conn shared` (<a href="https://libreswan.org/wiki/FAQ#Android_6.0_connection_comes_up_but_no_packet_flow" target="_blank">Reference</a>). Indent lines with two spaces. When finished, run `service ipsec restart`.

Once connected, you will see a VPN icon in the notification bar. You can verify that your traffic is being routed properly by <a href="https://encrypted.google.com/search?q=my+ip" target="_blank">looking up your IP address on Google</a>. It should say "Your public IP address is `Your VPN Server IP`".

### iOS ###
1. Go to Settings -> General -> VPN.
1. Tap **Add VPN Configuration...**.
1. Tap **Type**. Select **L2TP** and go back.
1. Tap **Description** and enter anything you like.
1. Tap **Server** and enter `Your VPN Server IP`.
1. Tap **Account** and enter `Your VPN Username`.
1. Tap **Password** and enter `Your VPN Password`.
1. Tap **Secret** and enter `Your VPN IPsec PSK`.
1. Make sure the **Send All Traffic** switch is ON.
1. Tap **Done**.
1. Slide the **VPN** switch ON.

Once connected, you will see a VPN icon in the status bar. You can verify that your traffic is being routed properly by <a href="https://encrypted.google.com/search?q=my+ip" target="_blank">looking up your IP address on Google</a>. It should say "Your public IP address is `Your VPN Server IP`".

### Chromebook ###
1. If you haven't already, sign in to your Chromebook.
1. Click the status area, where your account picture appears.
1. Click **Settings**.
1. In the **Internet connection** section, click **Add connection**.
1. Click **Add OpenVPN / L2TP**.
1. Enter `Your VPN Server IP` for the **Server hostname**.
1. Enter anything you like for the **Service name**.
1. Make sure **Provider type** is **L2TP/IPSec + pre-shared key**.
1. Enter `Your VPN IPsec PSK` for the **Pre-shared key**.
1. Enter `Your VPN Username` for the **Username**.
1. Enter `Your VPN Password` for the **Password**.
1. Click **Connect**.

Once connected, you will see a VPN icon overlay on the network status icon. You can verify that your traffic is being routed properly by <a href="https://encrypted.google.com/search?q=my+ip" target="_blank">looking up your IP address on Google</a>. It should say "Your public IP address is `Your VPN Server IP`".

## Acknowledgement

This document was adapted from the <a href="https://github.com/jlund/streisand" target="_blank">Streisand</a> project by Joshua Lund and contributors.

## License

Copyright (C) 2016 Lin Song   
Based on <a href="https://github.com/jlund/streisand/blob/master/playbooks/roles/l2tp-ipsec/templates/instructions.md.j2" target="_blank">the work of Joshua Lund</a> (Copyright 2014-2016)

This program is free software: you can redistribute it and/or modify it under the terms of the <a href="https://www.gnu.org/licenses/gpl.html" target="_blank">GNU General Public License</a> as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
