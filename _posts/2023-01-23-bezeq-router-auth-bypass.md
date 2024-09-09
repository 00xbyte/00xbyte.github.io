---
title: Bezeq Router Auth-Bypass
categories:
- Research
tags:
- IoT
- Auth-Bypass
- Info-Leak
image: /assets/img/post/router_login.jpeg
authors:
- 00xbyte
---

# Intro
I want to share with you a cute little vulnerability I found ([CVE-2022-47848](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-47848)).  
Two models of Bezeq's routers, Vtech NB603-IL and Vtech IAD604-IL are vulnerable to authentication bypass.
# The vulnerability
These routers use their serial number as a password to the admin panel on port 80/443. 

![]({{ 'assets/img/post/router_login.jpeg' | relative_url }}){: width="540" height="400" }

These routers also have a UPnP service open on port 8200.
Requesting the page `/rootDesc.xml` from the UPnP service retrieves an XML file containing the device's serial number.
Thus an attacker in the network can log in and compromise it.

![]({{ 'assets/img/post/router_xml.jpeg' | relative_url }}){: width="540" height="400" }



# The flawed logic
The serial number appears on a sticker on the back of the router, so allegedly the only way to obtain it (and log in) is by physically accessing the router.
The flaw is that the serial number was considered private information by one process but public information by another, so any unauthorized user could obtain it.

To sum up, this vulnerability is exploitable by any attacker who is accessible to these routers' ports via LAN (a few devices are exploitable from the WAN).

# Affected Versions


| Model | Software Version |
| -------- | -------- |
| NB403-IL   |  `BZ_2.02.07.09.13.01`     | 
|IAD604-IL |  `BZ_2.02.07.09.13.01`, `BZ_2.02.07.09.13T`, `BZ_2.02.07.09.09T`   | 



# Disclosure process
- 7/12/22 -I Informed Bezeq via their general-purpose email that I have found a vulnerability in their products. No response. 
- 17/12/22 - CVE request to MITRE
- 17-27/12/22 - Contacted Bezeq several times with no response.
- 28/12/22 - First response from Bezeq via Instagram, and full disclosure of the vulnerability details.
- 16/1/23 - After weeks with no response, I informed Bezeq that because they do not show intentions to fix the vulnerability, I will publish the details publicly soon.
- 23/1/23 - Bezeq's CISO called to confirm the vulnerability but did not state whether or when they were going to fix the issue.
- 5/2/23 - Contacted Bezeq again stating that 60 days have passed since I first reached out about the vulnerability, and asked whether a patch is even planned. No response.
- 21/2/23 - Meeting at Bezeq's offices in which I have fully described the issue and helped perform risk assessment.
- 6/3/23 - Bezeq  closed the ports of WAN-exposed devices, thus minimizing the potential threat of exploitation, but no further action was taken place.
- 8/3/23 - Publicly posting.
- 1/9/23 - Obtained CVE from MITRE - [CVE-2022-47848](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-47848)

# Closing thoughts
My overall impression of Bezeq is that the security of their customers is important to them as they acted rather quickly to protect WAN-exposed devices after understanding the potential threat. I would have expected Bezeq to fix the issue however sadly they did not.
They were also very nice to invite me to their offices to speak with them about the issue and they gave me a warm thank you (no bug bounty though).
My main caveat is their painfully slow response times to my initial attempts to contact them about the issue, and because they are the biggest ISP in Israel, I would have assumed they had an IR team.
Later on, Bezeq pointed out that the email address that appeared on their site (the one I contacted) was outdated, and that caused the long delays to answer.
