---
title: Physical Security
categories:
- Real World
tags: []
image: assets/img/post/keypad.jpeg
---

# Intro
Today I want to talk with you about physical security and showcase some examples of security flaws.
Although many times it does not feel like it, we still live in a physical world where damage and exploitation can be done with a physical presence. Our most sensitive data is stored in server rooms, inside buildings, and even "The Cloud" resides on a physical server somewhere.
Thus, the importance of properly securing our physical assets does not fall short of protecting them digitally.
Here are a few examples lacking physical security:
# Example 1 - Worthless Keypads
These are 2 keypads I have come across in Tel Aviv. Both of these fail to fulfill their purpose as they reveal the access code in worn-out pads. These doors are practically unlocked.

![]({{ 'assets/img/post/keypad.jpeg' | relative_url }}){: width="500" height="400" }
# Example 2 - Using a lock with a public key
While riding a train by Israel Railways , something caught my eye. Both the trash bin and the train management panels had the same lock! It is generous of me to even call it a lock. The "lock" was a screw that could be opened by a very common wrench
My biggest problem with this implementation is that a crucial piece of the train's infrastructure can be opened and sabotaged by anyone with a wrench.
My second issue is that there is a single layer of authorization. You need the same level of authorization to clean a trash can and interact with the management panel. Maybe it was intentionally designed this way because a single team is responsible for both? I don't know.

![]({{ 'assets/img/post/train.jpeg' | relative_url }}){: width="500" height="400" }
