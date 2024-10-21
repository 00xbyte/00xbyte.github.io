---
title: Hacking Dash Cams
categories:
- Research
tags:
- IoT
- Auth-Bypass
- Info-Leak
- Car
- Camera
image: /assets/img/post/proof_logo.jpeg
authors:
- 00xbyte
---

# Intro
As the entire world races torwards connectivity, time-to-market is often prioritized over security.  
In today's episode - finding vulnerabilities in smart car appliences!

If you recognize one of the logos in the picture above, you might be at risk! Improper authorization may lead to unauthorized access to smart car appliences (dash cams, car infotainment systems), granting access to location history, videos and more.

## Affected Vendors:
- Szime
- Proof.co.il (Fixed)

After several attempts to contact both vendors (on multiple channels) for over a year, I am publishing the details of this vulnerability so that users can protect themselves from vehicle surveillance.  
Proof.co.il have confirmed and fixed the issue, but Szime have not responded.


# The vulnerability

## Intro to the system
When a customer buys a new device, they download the associated app and register their appliance to the app with a unique identifier called `IMEI`. This process is called device binding. **Once a user binds a camera to their phone, they have full controll over it and can access all of its features, including location history and videos.**

## Issue #1 - IMEI numbers are predictable
I have found that IMEI numbers are constructed from 14 digits where the first 13 digits are the identifier and the last digit is a checksum digit calculated by [the Luhn algorithm](https://en.wikipedia.org/wiki/Luhn_algorithm).  
The problem is that the IMEI numbers are sequential.
If for example your car cam has the IMEI `01234567891233`, then there is a good chance that the previous IMEI `01234567891225` belongs to another camera.

There is also an API request to check if an IMEI exists:  
First, login to obtain an `access_token`
```
POST /oauth/token HTTP/1.1
...

grant_type=password&client_id=app&client_secret=api1234&scope=SCOPE_READ&username=xxxxxxxxxx&password=yyyyyyyyyy
```
(🤦‍♂️ lets take a second to appreciate this marvelous secret api key embedded in the client app: `api1234`)  
`username` being a phone number.

Then check if the IMEI exists:
```
GET /api/v2/user/sendbindreq?access_token=xxxxxxxxx&did=yyyyyyyyyyyyyy HTTP/1.1
...

```
`did` is the device id - aka IMEI.

This allows an attacker to brute-force their way to retreive all the existing IMEIs.  
Because the api has no way to validate whether the owner of the phone that binding to a new camera is also the owner of that camera, then:  
**Any user can register to themselves any unregistered camera by guessing the IMEI**

Futhermore, the IMEI number is visible on some devices (like dash cams) and allows pedestrians to look through the car window and obtain the IMEI number.

![image 1]({{ 'assets/img/post/proof_imei.jpg' | relative_url }}){: width="540" height="400" }

Because all of the IMEIs were already flashed on to the cameras, **unfortinately this issue can not be fixed!**  

## Issue #2 - 'Stealing' a binded camera
We have established that once a camera is binded to a phone, only they have access to its features.  
But what if an attacker was able to "steal" a camera by binding it to their phone? Unfortunately this is possible.  
I have found that the debind process is not properly authorized. Take a look:

If an attacker sends this "debind" request with the `imei` being the victim's device's IMEI:
```
POST /api/v2/user/debinddev?access_token=xxxxxxxxx HTTP/1.1
...

{"imei":"yyyyyyyyyyyyyy" }
```
There is no validation that the request initiator is the owner of the device and the device is unbinded immediately!  
This means **any user with an account can debind any device given its IMEI number!**

Next, all the attacker needs to do is bind the device to thier account with the following request:
```
POST /api/v2/user/binddev?access_token=xxxxxxxxx HTTP/1.1
...

{"name":"yyyyyyyyyy","imei":"zzzzzzzzzzzzzz", "nick":"notImportant"}
```
`name` being the phone number.

Thats it! The device is now binded to their account and they have access to all of the deivce's live and recorded data!

### Backend Code (Guess)

Although I have no way of knowing what code runs on the backend servers, this is my guess of how the code looks like if it is written in python with the flask framework:
```py
@app.route('/api/v2/user/debinddev', methods=['POST'])
def debind_dev():
    access_token = request.args.get('access_token')
    imei = request.json.get('imei')

    if not access_token or not imei:
        return "Bad Args"

    response = db.verify_access_token_valid(access_token)
    if not response.is_ok:
        return "Bad Token" 

    db.debind_camera(imei)
    return "OK"
```

### The Fix (Guess)
This is what I assume the fix looks like:
```py
@app.route('/api/v2/user/debinddev', methods=['POST'])
def debind_dev():
    access_token = request.args.get('access_token')
    imei = request.json.get('imei')

    if not access_token or not imei:
        return "Bad Args"

    response = db.verify_access_token_valid(access_token)
    if not response.is_ok:
        return "Bad Token" 

    # --------- FIX -----------
    user = db.get_user_for_access_token(access_token)
    if user.does_own_camera(imei):
        return "Bad Permissions" 
    # -------------------------

    db.debind_camera(imei)
    return "OK"
```

## Bonus Issue - Registration without phone validation
There is no validation the the registered phone number belongs to the user. No SMS, nothing.  
This issue makes these attacks easier because this removes the requirement for an active phone number and allows the whole attack to be executed from a script!
```
POST /api/v2/user/register HTTP/1.0
...

{"pn":"xxxxxxxxxx", "pwd":"yyyyyyyyyy"}
```
`pn` stands for phone number, and `pwd` for password


# Mitigation

I have received confirmation that Proof.co.il have fixed the issue on thier servers. On the other hand, Szime did not respond, so until they fix this issue, I recommend that Szime users disconnect thier devices from the internet.  
Szime, if you are reading this, please stop ghosting security researchers.
