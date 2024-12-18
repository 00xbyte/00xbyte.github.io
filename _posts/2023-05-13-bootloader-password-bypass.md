---
title: Hacking A Bootloader
categories:
- Research
tags:
- IoT
- Bootloader
image: /assets/img/post/uart.jpg
authors:
- 00xbyte
description: Hacking and bypassing bootloader password. Router firmware meets a security researcher, with an ISP's desperate attempt to implement security. Take contorl over your router and flash custom firmware!
---

There is a saying that you don't truly own a router until you flash your own firmware on it.
The only problem was that the bootloader of my router was password protected.
So I accepted the challenge :) 

> Disclaimer - My ISP is the biggest one in Israel, and this is their newest router.
> They market it as "BCyber" (spoiler alert - not much cyber ahead)

Opening up the router, I found 4 pins that I assumed were debug pins.

![image 1]({{ 'assets/img/post/uart.jpg' | relative_url }}){: width="540" height="400" }

Using a multimeter I identified which was ground, TX, and RX. I connected a UART-to-USB connector to my computer, used my favorite serial com tool - screen, booted up the router and there was the boot log!

*This router was a Little Endian ARM Broadcom BCM963XXX and ran a CFE bootloader.*

Upon boot, I quickly pressed some keys in order to stop the boot process before the OS was loaded, and was prompted with the CFE prompt.
The only problem was that the bootloader was password protected, and did not let me enter any command. Any input I entered, resulted in the same message:

```
please enter the password!
CFE> 
```
{: file='/dev/ttyUSB0'}

Assuming my ISP probably customized the bootloader, and knowing fair well that they most likely didn't do a very good job, I decided to try to find the password.

I had the router's firmware lying around, so I extracted it with binwalk and loaded the bootloader into my dear friend IDA to take a closer look at the password validation process.
After opening the bootloader in IDA, my first task was to find the image load address.

I noticed that many function use pointers with a similar base address (`0xFxxxxx`)


![]({{ 'assets/img/post/address.png' | relative_url }})

My immediate guess was an image base address of `0xF00000`. After fiddling around to find the exact address it turned out  to be `0xF00000 - 12` (for some reason).

Now, with addresses correctly mapped, I can use cross-references to strings in order to navigate inside the boot loader. A quick search brought me to the function that validates the password.

![]({{ 'assets/img/post/cfe_prompt.png' | relative_url }})

Now all that is left is to figure out what the password is.

![]({{ 'assets/img/post/cfe_password.png' | relative_url }})

As you can see, the password is calculated using the last 3 bytes of the MAC address in reverse order.
I entered the password into the CFE prompt and success! I can now flash my own firmware.

![image 5]({{ 'assets/img/post/cfe_uart.png' | relative_url }})

That's it! I hope you enjoyed our short journey.
