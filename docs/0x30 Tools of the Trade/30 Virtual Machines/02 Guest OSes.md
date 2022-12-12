---
title: "Guest OSes"
---

# The Tyranny of Choice

When it comes to guest OSes, there are a lot of options. However, for the purposes of malware development and analysis, you'll want (at a minimum) a Windows and a Linux guest VM; preferably more than one of each.

## Malware Development

For creating malware, you'll want a fully-featured development environment, with support for multiple programming languages and a solid IDE. Thankfully, there are some excellent pre-made solutions for this purpose:

* [Windows 11 Development Environment](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/)
    * A fully-featured development environment for Windows 11, including Visual Studio 2022 and a full suite of tools and languages.
    * This VM is _huge_, but comes with everything you need to get started with Windows development.
    * The VM expires after 90 days, but can be re-downloaded.
* [Pop!_OS](https://pop.system76.com/)
    * A Linux distribution based on Ubuntu, aimed at software developers.
    * Well-suited for a variety of languages, including C, C++, Python, and Go.
* [Kali Linux](https://www.kali.org/)
    * A Linux distribution based on Debian, aimed at penetration testers.
    * Includes tools for generating shellcode and other malware payloads.
* [Parrot Security OS](https://www.parrotsec.org/)
    * A Linux distribution based on Debian, aimed at penetration testers and security professionals.
    * Includes custom-tailored editions for developers, penetration testers, and more.

At a minimum, you'll want at least one Windows development VM and one Linux VM, with the ability to create shellcodes and other malware implants. For this purpose, `Parrot OS` is a solid choice, though `Kali` and `Pop!` are also good options.

## Malware Analysis

For running and analyzing malware, you'll want a separate VM from your development systems. This is to prevent any accidental damage to your development environment, and to ensure that your malware analysis environment is as clean as possible. For this purpose, you'll want a VM that is as close to a "vanilla" installation as possible, with few modifications. This will help ensure that any changes to the system are caused by the malware, and not by the analyst. The following are some excellent options for analysis guest VMs:

* [Windows Testing VMs](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/)
    * A collection of Windows VMs, including Windows 7, Windows 8.1, and Windows 10, with Internet Explorer or Edge browsers pre-installed.
    * These VMs contain very little additional software, and are very close to a "vanilla" installation.
    * They expire after 90 days, but can be re-activated or rolled back to a clean, "un-registered" state.
    * For testing on Windows 11, it may be necessary to use the [Windows 11 Development Environment](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/) VM, as the Windows 11 Testing VMs are not yet available.
* [Remnux](https://remnux.org/)
    * An open-source and free Linux-based toolkit specifically designed for malware analysts.
    * Contains an extensive suite of malware analysis and reverse-engineering tools.
* [Flare VM](https://github.com/mandiant/flare-vm)
    * While technically not a full VM in its own right (due to Windows license restrictions), Flare VM is a set of scripts that install and configure a full suite of analysis and reversing tools for Windows.
    * This is a great option for analysts who already have a Windows VM, but want to add a full suite of analysis tools.
    * Alternatively, one could download and install each tool individually, but this is a time-consuming process.