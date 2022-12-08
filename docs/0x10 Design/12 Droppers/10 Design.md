---
title: "Step 0: Designing a Dropper"
---

# Putting it all Together

In the [introduction to droppers](/0x10%20Design/12%20Droppers/00%20Intro/#dropper-examples), we introduced Maldocs, as well as LNK, ISO and HTML droppers. After maldocs were crippled in 2022, threat actors adopted the other three methods, often in combination. In this section, we'll design our own dropper, mirroring a common attack pattern observed in malicious phishing email attachments.

## Design Goals

Phishing emails are the most common method by which malware is distributed. Therefore, we'll design our dropper as an HTML email attachment. Since this is a [Proof-of-Concept](https://en.wikipedia.org/wiki/Proof_of_concept) (PoC), rather than a proper phishing email intended to deceive a real victim, we won't spend much time on disguising the HTML to look like a legitimate website. (Real-world attackers often send HTML attachments without any visible content at all, so this isn't a huge sacrifice.) Instead, we'll just focus on the essentials of this common attack pattern:

`Phishing Email -> HTML -> ISO -> LNK -> Stager`

1. We'll create an HTML attachment designed to be sent via phishing email.
2. The HTML will contain a Base64-encoded ISO, as well as some JavaScript code.
3. The JavaScript will decode and "download" the ISO to the victim's computer.
4. The ISO will contain a hidden directory and a LNK file, disguised as a WordPad document.
5. The LNK file will launch a PowerShell stager located in the hidden directory.

Since our focus is dropper desgign, we'll use a simpel PoC stager, which will create a file called "INFECTED.TXT" on the victim's desktop, then exit. When the dropper is complete, it should be easy enough to swap out the PoC stager for something more robust.

## Build Process

Now that we've defined our dropper's attack chain chronologically, we can begin building the dropper. It's important to note how each step depends on the others. The phishing email depends upon the existence of the HTML file, which depends upon the existence of the ISO, which is constructed from the LNK and stager code. Therefore, we'll need to build the dropper in reverse; once we've got a stager, we can create the LNK file. With these in-hand, we'll construct the ISO, which we'll then encode and embed into the HTML file, along with the JavaScript code necessary to trigger the download. Only then will the final HTML dropper be complete.

## Requirements

To build this dropper, we'll need access to a [Windows VM](/0x30%20Tools%20of%20the%20Trade/Virtual%20Machines/02%20Guest%20OSes/#malware-development) with PowerShell installed.