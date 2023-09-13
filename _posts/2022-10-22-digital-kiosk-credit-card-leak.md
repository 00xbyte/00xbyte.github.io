---
title: Leaking Credit Card Numbers In A KFC
categories:
- Real World
tags:
- Credit-Card
- Info-Leak
---

One of the reasons I love being a security researcher is that the foolish and curious child in me never dies. I frequently ask myself what would happen if I did this and that.

The other day I entered a KFC and placed my order through a self-service kiosk.
As I began my order I was prompted with a popup offering to login into a membership account via a phone number or coupon code.
I did not have a membership so my phone number was not in the system, but the coupon code option was interesting.
I inferred that the minimum length of a coupon code was a 4-digit number and that got me thinking... What would happen if I enter 1234?

To my surprise, I logged in with no form of authentication!
**Any number combination I entered** greeted me with a personal welcome message, along with "my" cellphone number, birthday, and the first 10 digits of "my" credit card number ("my" being a registered member).

![]({{ 'assets/img/post/tabit.png' | relative_url }}){: width="540" height="400" }

Combining the first 10 digits of the credit card shown on the screen with the last 4 digits printed on a receipt leaves me 2 digits to guess.
Commonly, the last digit of a credit card is a "check digit" that ensures the integrity of the whole number.
This digit is usually calculated with the [Luhn algorithm](https://en.m.wikipedia.org/wiki/Luhn_algorithm) which narrows the combinations of the 2 missing digits from 100 to at most 50.

This is a great example of an IDOR (Insecure direct object reference) vulnerability that could have been prevented with the use of OTP.

After reporting this vulnerability to KFC, I was informed that this vulnerability may apply to other restaurants (countrywide) using Tabit - Restaurant Technologies's management system!

As any white hat researcher would do, I disclosed my findings to Tabit and gave them a chance to fix the issue before posting this publicly.
Much appreciation is given to Tabit who responded immediately to the issue and addressed it with all the necessary attention. It seems that they take their customer's privacy very seriously.
