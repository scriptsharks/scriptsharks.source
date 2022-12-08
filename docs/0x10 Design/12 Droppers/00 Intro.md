---
title: "Dropper Basics"
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

# Dropper Examples

## The Maldoc

When it comes to dropper design, simplicity is key. Historically, Microsoft Office was one of the most popular tools for creating malware droppers. This was partly due to the suite's global popularity, as well as the inclusion of a built-in scripting language, VBA.

Creating a "maldoc" dropper was fairly simple. To start, the attacker would have a malware stager, often in the form of a PowerShell script, which could be delivered as a "one-liner" or as a script. The attacker would then create a Microsoft Word or Excel document, and embed the stager in the document as a VBA macro. When opened, the maldoc would execute the embedded macro-script, which would in turn launch the stager.

This approach was highly effective due to the prevalence of Mirosoft Office in corporate environments. Employees commonly sent and received Office documents via email as part of their job duties, so they rarely thought twice about opening a maldoc.

However, in July of 2022, Microsoft released a patch that disabled VBA macros by default, which crippled the effectiveness of "maldoc" droppers. In response, threat actors have migrated to other dropper techniques.

## The LNK Dropper

Malware authors are quite familiar with abusing Microsoft Windows Shortcut (`.lnk`) files. In 2010, attackers abused a [Windows 0-day](https://learn.microsoft.com/en-us/security-updates/securitybulletins/2010/ms10-046) to distribute the [Stuxnet Worm](https://support.radware.com/ci/okcsFattach/get/15458_3). In 2012, hackers used `.lnk` files to [steal password hashes](https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/you-down-with-lnk/) from unsuspecting users. In 2013, `.lnk` files were used to [recombine fragmented malware](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=1d5f06a6-c969-4678-91be-afbb864a696c&CommunityKey=1ecf5f55-9545-44d6-b0f4-4e4a7f5f5e68&tab=librarydocuments) prior to execution. In 2014, malware authors used `.lnk` files to launch malware which had been [renamed with benign-looking file extensions](https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/lnk-files-in-email-malware-distribution/), such as `.pdf` and `.doc`. This was possible because `cmd.exe` used the `CreateProcess` API, which checked for the presence of PE headers, rather than using the file's extension, to determine how it should be handled.

In 2015, attackers used `.lnk` files to [hide malware execution](https://www.avira.com/en/blog/lnk-files-shortcuts-faster-infections) on target systems. The method was pretty straightforward:

1. Set the "hidden" attribute of a legitimate file or directory on the target system, so that the user can no longer see it.
2. Drop a malicious script or executable on the system, also hidden.
3. Create a `.lnk` file which masquerades as the legitimate file or directory, but which launches the malware before opening the expected file.

This was as simple as creating a shortcut, then modifying its "target" attribute to point to `cmd.exe` with a crafted command line, like so:

```sh
cmd.exe /c start malware.vbs & start legit_file.exe & exit
```

This would launch `malware.vbs`, then `legit_file.exe`, and then exit. To an unobservant user, it would appear as if the shortcut was simply opening the expected file.

## The ISO Dropper

Much like [ZIP files](https://en.wikipedia.org/wiki/ZIP_(file_format)), ISO files are archives that wrap multiple files into one. ISOs were originally designed for creating backups of optical media, such as CD-ROMs. In early versions of Windows, users had to install special third-party tools in order to work with ISO files. This changed in 2012, when Microsoft added native ISO support to Windows 8, allowing users to be mount ISO files as virtual drives. By 2017, malware authors were [taking full advantage](https://cofense.com/new-phishing-emails-deliver-malicious-iso-files-evade-detection/) of this feature, using ISO files as a delivery mechanism for malware.

The early ISO droppers were fairly simple, containing a malicious `.exe` file masquerading as an Office document or PDF. Attackers would simply attach the ISO to outbound phishing emails, often masquerading as purchase orders, receipts, or other official-looking documents. Unsuspecting users would open the ISO and execute the malware within. This method was surprisingly effective, considering how little the attackers did to disguise the dropper.

## The HTML Dropper

Adversaries have been abusing HTML and in-browser scripting languages since the dawn of time (or at least [since 1998](https://www.wired.com/1998/11/virus-thrives-on-html/)). This trend continued [into the 2010s](https://www.virusbulletin.com/virusbulletin/2010/10/it-s-just-spam-it-can-t-hurt-right), and still takes place [today](https://blog.barracuda.com/2022/06/28/threat-spotlight-malicious-html-attachments/). With HTML and JavaScript, attackers can easily create an inconspicuous-looking dropper by embedding a Base64-encoded malware package within a JavaScript wrapper which, when the HTML file is opened, will trigger a "download" of the decoded package to the user's hard drive.

This dropper method is popular for a number of reasons: it doesn't involve common red-flag file extensions (like `.exe`, `.dll`, `.ps1`, etc.); embedded JavaScript code can be obfuscated to hide their contents from email attachment scanners; and it's easy to mimic the look of a trustworthy website, aiding in deception.
