---
title: Bypassing Router Bootloader Protection
date: 2023-05-21
categories: [Reverse Engineering]
tags: [IoT, Bootloader]
---

There is a saying that you don't truly own a router until you flash your own firmware on it.
The only problem was that the bootloader was password protected.
So I accepted the challenge :) 

> Disclaimer - My ISP is the biggest one in Israel, and this is their newest router.
> They market it as "BCyber" (spoiler alert - not much cyber ahead)

Opening up the router, I found 4 pins that I assumed were debug pins.

image 1

Using a multimeter I identified which was ground, TX, and RX. I connected a UART-to-USB connector to my computer, used my favorite serial com tool - screen, booted up the router and there was the boot log!

*This router was a Little Endian ARM Broadcom BCM963XXX and ran a CFE bootloader.*

Upon boot, I quickly pressed some keys in order to stop the boot process before the OS was loaded, and was prompted with the CFE prompt.
The only problem was that the bootloader was password protected, and did not let me enter any command. Any input I entered, resulted in the same message:
```
please enter the password!
CFE> 
```

Assuming my ISP probably customized the bootloader, and knowing fair well that they most likely didn't do a very good job, I decided to try to find the password.

I had the router's firmware lying around, so I extracted it with binwalk and loaded the bootloader into my dear friend IDA to take a closer look at the password validation process.
After opening the bootloader in IDA, my first task was to find the image load address.

I noticed that many function use pointers with a similar base address (`0xFxxxxx`)


image 2

My immediate guess was an image base address of `0xF00000`. After fiddling around to find the exact address it turned out  to be `0xF00000 - 12` (for some reason).

Now, with addresses correctly mapped, I can use cross-references to strings in order to navigate inside the boot loader. A quick search brought me to the function that validates the password.

image 3

Now all that is left is to figure out what the password is.

image 4

As you can see, the password is calculated using the last 3 bytes of the MAC address in reverse order.
I entered the password into the CFE prompt and success! I can now flash my own firmware.

image 5

That's it! I hope you enjoyed our short journey.