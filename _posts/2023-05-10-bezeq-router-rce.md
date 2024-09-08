---
title: Bezeq Router RCE
categories:
- Reverse Engineering
tags:
- IoT
- Auth-Bypass
- RCE
- Backdoor
authors:
- 00xbyte
---

# Intro
There is a saying that you don't truly own a router until you root it. So i accepted the challenge with my ISP's router.
This is the same router from my previous posts a customized `Broadcom BCM963XXX`.
I had the firmware laying around and a spare router for testing so all that was left was diving in to the research.
# The RCE
## Triggering telnet
By default there are aren't many open services on the router other than the web service, so i thought that would be a good place to start.
Reverse engineering the router's web server revealed that if you send a GET request to the web server at the path `/twgjtelnetopen.cmd` the router opens a telnet process!

![]({{ 'assets/img/post/telnet_trigger.png' | relative_url }}){: width="540" height="400" }

I immediately tried to make the request and it worked!

![]({{ 'assets/img/post/backdoor_trigger.png' | relative_url }}){: width="540" height="400" }
## Bypassing Authentication
Connecting to the telnet port resulted in a login prompt, in which I discovered the username and password are the same as the web service credentials. This means that the username is `Admin` and the password is comprised of the last 6 characters of the router's serial number.  
At this point I thought to use the [previous vulnerability]({% post_url 2023-01-23-bezeq-router-auth-bypass %}) I found, in order to leak the password. In this model, the UPNP service ran on port 5431 instead of 8200 like the previous one.
This model again behaved differently than the previous one, where it only leaked the last 4 characters of the serial number. That meant that I had to brute force the remaining 2 alphanumeric characters.
## "Jailbreak"
After logging in, I was presented with a support console with a few supported commands. As I went through the possible commands, one immediately caught my eye - ping.
It is amazing to me how many vendors to this day still fall for this. There is a command injection in the ping argument!
`ping ;echo pwned`
## A Better "Jailbreak"
This was too poor of an ending to my research, so I went on to look at an `.SO` file that the telnet process loaded. After a quick glance, I saw something funny, there are 2 functions that handle user commands.

![]({{ 'assets/img/post/cli_hidden_commands.png' | relative_url }}){: width="540" height="400" }

The first function implemented the commands that were listed by the "help" commands, and the second function implemented multiple other ***hidden*** commands.
Among those undocumented commands, was the `openfsshell` command that grants a full bash shell.

![]({{ 'assets/img/post/backdoor_connect.png' | relative_url }}){: width="540" height="400" }
## Closing Thoughts
Clearly the hidden telnet service and hidden cli commands are meant to be used for maintenance, but 'security by obscurity' is a weak practice. There are better ways to implement maintenance functionalities in software, that require propper authorization.

For example a challenge response scheme with an asymmetric key pair:
1. The maintenance person requests access the the debug panel
2. The router prompts them with a challenge
3. The maintenance person solves the challenge using the companies private key (via some api)
4.  The router validates the response using the companies public key
