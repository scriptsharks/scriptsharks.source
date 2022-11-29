---
title: "Droppers"
---

# What's a Dropper?

A dropper is a small, self-contained mechanism for delivering a malware stager to a target system. Like a gift-wrapped box, it is designed to entice users to open it and retrieve the gift inside. Droppers and stagers are often coupled, and the terms are often used interchangeably, but I prefer to make a distinction between the two.

## Core Features

Malware droppers should aim for the following features:

* **Small size.** Droppers should be as small as possible, to minimize the amount of data that must be downloaded. This is especially important for droppers that are delivered via email, where the size of the attachment is limited.
* **Self-contained.** Droppers should be self-contained, meaning that they do not require an internet connection, nor any non-standard files or libraries, in order to function. This allows droppers to function on as many systems as possible.
* **Low-privilege.** Droppers should run without administrative privileges, so they can be executed even by unprivileged users.
* **Non-malicious.** Droppers should not take any malicious actions on their own. Their sole purpose is to deliver a stager to a target system. This helps to avoid detection and prevention by system security software.
* **Stager-independent.** Droppers should be decoupled from the stagers they deliver, so that components can be replaced with minimal effort.