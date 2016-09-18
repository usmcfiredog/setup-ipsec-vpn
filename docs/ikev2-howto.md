﻿# How To: IKEv2 VPN for Windows 7 and newer

*Read this in other languages: [English](ikev2-howto.md), [简体中文](ikev2-howto-zh.md).*

---

**IMPORTANT:** This guide is for **advanced users** ONLY. Other users please use <a href="clients.md" target="_blank">IPsec/L2TP</a> or <a href="clients-xauth.md" target="_blank">IPsec/XAuth</a>.

---

Windows 7 and newer releases (including Windows Phone 8.1 and newer) support the IKEv2 and MOBIKE standards through Microsoft's Agile VPN functionality. Internet Key Exchange (IKE or IKEv2) is the protocol used to set up a security association (SA) in the IPsec protocol suite. Compared to IKEv1, IKEv2 has <a href="https://en.wikipedia.org/wiki/Internet_Key_Exchange#Improvements_with_IKEv2" target="_blank">many improvements</a> such as Standard Mobility support through MOBIKE, and improved reliability.

Libreswan can authenticate IKEv2 clients on the basis of X.509 Machine Certificates using RSA signatures. This method does not require an IPsec PSK, username or password. Besides Windows, it can also be used with <a href="https://wiki.strongswan.org/projects/strongswan/wiki/AndroidVpnClient" target="_blank">strongSwan Android VPN client</a>. The following examples show how to configure IKEv2.

First, make sure you have successfully <a href="https://github.com/hwdsl2/setup-ipsec-vpn" target="_blank">set up your VPN server</a>. Commands below must be run as `root`.

1. Find the public and private IP of your server, and make sure they are not empty. It is OK if they are the same.

   ```bash
   $ PUBLIC_IP=$(dig @resolver1.opendns.com -t A -4 myip.opendns.com +short)
   $ PRIVATE_IP=$(ip -4 route get 1 | awk '{print $NF;exit}')
   $ echo "$PUBLIC_IP"
   (Your public IP is displayed)
   $ echo "$PRIVATE_IP"
   (Your private IP is displayed)
   ```

1. Add a new IKEv2 connection to `/etc/ipsec.conf`:

   ```bash
   $ cat >> /etc/ipsec.conf <<EOF

   conn ikev2-cp
     left=$PRIVATE_IP
     leftcert=$PUBLIC_IP
     leftid=@$PUBLIC_IP
     leftsendcert=always
     leftsubnet=0.0.0.0/0
     leftrsasigkey=%cert
     right=%any
     rightaddresspool=192.168.43.10-192.168.43.250
     rightca=%same
     rightrsasigkey=%cert
     modecfgdns1=8.8.8.8
     modecfgdns2=8.8.4.4
     narrowing=yes
     dpddelay=30
     dpdtimeout=120
     dpdaction=clear
     auto=add
     ikev2=insist
     rekey=no
     fragmentation=yes
     forceencaps=yes
     ike=3des-sha1,aes-sha1,aes256-sha2_512,aes256-sha2_256
     phase2alg=3des-sha1,aes-sha1,aes256-sha2_512,aes256-sha2_256
   EOF
   ```

1. Generate Certificate Authority (CA) and VPN server certificates:

   ```bash
   $ certutil -S -x -n "Example CA" -s "O=Example,CN=Example CA" -k rsa -g 4096 -v 12 -d sql:/etc/ipsec.d -t "CT,," -2

   A random seed must be generated that will be used in the
   creation of your key.  One of the easiest ways to create a
   random seed is to use the timing of keystrokes on a keyboard.

   To begin, type keys on the keyboard until this progress meter
   is full.  DO NOT USE THE AUTOREPEAT FUNCTION ON YOUR KEYBOARD!

   Continue typing until the progress meter is full:

   |************************************************************|

   Finished.  Press enter to continue:

   Generating key.  This may take a few moments...

   Is this a CA certificate [y/N]?
   y
   Enter the path length constraint, enter to skip [<0 for unlimited path]: >
   Is this a critical extension [y/N]?
   N

   $ certutil -S -c "Example CA" -n "$PUBLIC_IP" -s "O=Example,CN=$PUBLIC_IP" -k rsa -g 4096 -v 12 -d sql:/etc/ipsec.d -t ",," -1 -6 -8 "$PUBLIC_IP"

   A random seed must be generated that will be used in the
   creation of your key.  One of the easiest ways to create a
   random seed is to use the timing of keystrokes on a keyboard.

   To begin, type keys on the keyboard until this progress meter
   is full.  DO NOT USE THE AUTOREPEAT FUNCTION ON YOUR KEYBOARD!

   Continue typing until the progress meter is full:

   |************************************************************|

   Finished.  Press enter to continue:

   Generating key.  This may take a few moments...

                   0 - Digital Signature
                   1 - Non-repudiation
                   2 - Key encipherment
                   3 - Data encipherment
                   4 - Key agreement
                   5 - Cert signing key
                   6 - CRL signing key
                   Other to finish
    > 0
                   0 - Digital Signature
                   1 - Non-repudiation
                   2 - Key encipherment
                   3 - Data encipherment
                   4 - Key agreement
                   5 - Cert signing key
                   6 - CRL signing key
                   Other to finish
    > 2
                   0 - Digital Signature
                   1 - Non-repudiation
                   2 - Key encipherment
                   3 - Data encipherment
                   4 - Key agreement
                   5 - Cert signing key
                   6 - CRL signing key
                   Other to finish
    > 8
   Is this a critical extension [y/N]?
   N
                   0 - Server Auth
                   1 - Client Auth
                   2 - Code Signing
                   3 - Email Protection
                   4 - Timestamp
                   5 - OCSP Responder
                   6 - Step-up
                   7 - Microsoft Trust List Signing
                   Other to finish
    > 0
                   0 - Server Auth
                   1 - Client Auth
                   2 - Code Signing
                   3 - Email Protection
                   4 - Timestamp
                   5 - OCSP Responder
                   6 - Step-up
                   7 - Microsoft Trust List Signing
                   Other to finish
    > 8
   Is this a critical extension [y/N]?
   N
   ```

1. Generate client certificate(s), and export the p12 file that contains the client certificate, private key, and CA certificate:

   ```bash
   $ certutil -S -c "Example CA" -n "winclient" -s "O=Example,CN=winclient" -k rsa -g 4096 -v 12 -d sql:/etc/ipsec.d -t ",," -1 -6 -8 "winclient"

   -- repeat same extensions as above --

   $ pk12util -o winclient.p12 -n "winclient" -d sql:/etc/ipsec.d

   Enter password for PKCS12 file:
   Re-enter password:
   pk12util: PKCS12 EXPORT SUCCESSFUL
   ```

   Repeat this step for additional VPN clients, but replace every `winclient` with `winclient2`, etc.

1. The database should now contain:

   ```bash
   $ certutil -L -d sql:/etc/ipsec.d

   Certificate Nickname                               Trust Attributes
                                                      SSL,S/MIME,JAR/XPI

   Example CA                                         CTu,u,u
   ($PUBLIC_IP)                                       u,u,u
   winclient                                          u,u,u
   ```

   Note: To delete a certificate, use `certutil -D -d sql:/etc/ipsec.d -n "Certificate Nickname"`.

1. Restart IPsec service:

   ```bash
   $ service ipsec restart
   ```

1. The `winclient.p12` file should then be securely transferred to the Windows client computer and imported to the Computer certificate store. The CA cert once imported must be placed (or moved) into the "Certificates" sub-folder under "Trusted Root Certification Authorities".

   Detailed instructions:   
   https://wiki.strongswan.org/projects/strongswan/wiki/Win7Certs

1. On the Windows computer, add a new IKEv2 VPN connection.

   https://wiki.strongswan.org/projects/strongswan/wiki/Win7Config

1. Start the new IKEv2 VPN connection, and enjoy your own VPN!

   https://wiki.strongswan.org/projects/strongswan/wiki/Win7Connect

   Once successfully connected, you can verify that your traffic is being routed properly by <a href="https://encrypted.google.com/search?q=my+ip" target="_blank">looking up your IP address on Google</a>. It should say "Your public IP address is `Your VPN Server IP`".

## Known Issues

The built-in VPN client in Windows 7 and newer does not support IKEv2 fragmentation. On some networks, this can cause the connection to fail with "Error 809", or you may be unable to open any website after connecting. If this happens, first try <a href="clients.md#troubleshooting" target="_blank">this workaround</a>. If it doesn't work, please connect using <a href="clients.md" target="_blank">IPsec/L2TP</a> or <a href="clients-xauth.md" target="_blank">IPsec/XAuth</a> instead.

## References

* https://libreswan.org/wiki/VPN_server_for_remote_clients_using_IKEv2
* https://libreswan.org/wiki/HOWTO:_Using_NSS_with_libreswan
* https://libreswan.org/man/ipsec.conf.5.html
* https://wiki.strongswan.org/projects/strongswan/wiki/Windows7
