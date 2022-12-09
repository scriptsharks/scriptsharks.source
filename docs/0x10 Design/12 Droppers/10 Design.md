---
title: "Step 0: Designing a Dropper"
---

# Putting it all Together

In the [introduction to droppers](/0x10%20Design/12%20Droppers/00%20Intro/#dropper-examples), we introduced Maldocs, as well as LNK, ISO and HTML droppers. After maldocs were crippled in 2022, threat actors adopted the other three methods, often in combination. In this section, we'll design our own dropper, mirroring a common attack pattern observed in malicious phishing email attachments.

## The Con

Phishing emails are the most common method by which malware is distributed. With this in mind, let's build a dropper for a hypothetical "fraudulent charge" phishing scam. In this common ruse, criminals pose as banks or online retailers, sending a "fraud prevention" notice to vitcims. The emails urge victims to respond quickly to avoid paying for a series of high-value purchases. We'll disguise our dropper as an invoice, attached to the phishing email, which will launch a malware stager.

## Design Goals

Since this is a [Proof-of-Concept](https://en.wikipedia.org/wiki/Proof_of_concept) (PoC) and not part of a real-world phishing campaign, we'll keep things simple and focus on the key elements of this common attack pattern:

`Phishing Email -> HTML -> ISO -> LNK -> Stager`

1. We'll create an HTML attachment designed to be sent via phishing email.
2. The HTML will contain a Base64-encoded ISO, as well as some JavaScript code.
3. The JavaScript will decode and "download" the ISO to the victim's computer.
4. The ISO will contain a hidden directory and a LNK file, disguised as a WordPad document.
5. The LNK file will launch a PowerShell stager located in the hidden directory.

Since our focus is dropper desgign, we'll use a minimal stager. When the dropper is complete, it should be easy enough to swap this out for something more robust.

## Build Process

Now that we've defined our dropper's attack chain chronologically, we can begin building the dropper. It's important to note how each step depends on the others. The phishing email depends upon the existence of the HTML file, which depends upon the existence of the ISO, which is constructed from the LNK and stager code. Therefore, we'll need to build the dropper in reverse; once we've got a stager, we can create the LNK file. With these in-hand, we'll construct the ISO, which we'll then encode and embed into the HTML file, along with the JavaScript code necessary to trigger the download. Only then will the final HTML dropper be complete.

## Requirements

To build this dropper, we'll need access to a [Windows VM](/0x30%20Tools%20of%20the%20Trade/Virtual%20Machines/02%20Guest%20OSes/#malware-development) with PowerShell installed.