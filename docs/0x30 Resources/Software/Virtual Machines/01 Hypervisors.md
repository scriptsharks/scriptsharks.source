---
title: "Hypervisors 101"
---

# Introduction

Hypervisors are generally broken down into two categories: Type 1 and Type 2. Type 1 hypervisors run directly on the hardware, while Type 2 hypervisors run on top of an existing OS. Type 1 hypervisors are generally more efficient, but Type 2 hypervisors are more flexible.

# Type 1 Hypervisors

For those with the extra hardware, Type 1 hypervisors are the way to go. They run on "bare metal," and are generally more efficient than Type 2 hypervisors. They also offer more control over the hardware, and can be configured to pass through hardware to the guest OSes. This allows for the use of specialized hardware, such as GPUs, sound cards, and USB devices, in the guest OSes. The following are some of the most popular Type 1 hypervisors:

* [VMware ESXi](https://www.vmware.com/products/esxi-and-esx.html)
    * ESXi is a bare-metal hypervisor that runs on top of a custom kernel.
    * Running a single server is fairly straightforward, but clustering requires commercial licensing.
* [Microsoft Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/)
    * Hyper-V runs atop 64-bit versions of Microsoft Windows, including Windows Server, as well as Windows 10 Pro, Enterprise and Education.
    * The functionality depends on the host OS, with some features only available in the server version, and others only in the desktop version.
* [Proxmox VE](https://www.proxmox.com/en/proxmox-ve)
    * Proxmox VE is a Debian-based hypervisor that uses KVM for virtualization.
    * The core is open-source and free, though a commercial subscription is available for additional features.

Personally, I've used a free single-host ESXi installation on a dedicated workstation for my home lab, and it's worked great.

# Type 2 Hypervisors

The two most popular Type 2 hypervisors are [VirtualBox](https://www.virtualbox.org/) and [VMware Workstation](https://www.vmware.com/products/workstation-pro.html). Both are free, and both are available for Windows, Linux, and macOS. The main difference between the two is that VirtualBox is open-source, while VMware Workstation is proprietary. VirtualBox is also more flexible, as it can run on top of any OS, while VMware Workstation requires Windows or Linux. For macOS, [VMware Fusion](https://www.vmware.com/products/fusion.html) is available, which provides similar functionality to VMware Workstation. However, _it will not run on newer Apple Silicon hardware_, such as the M1 and M2 chipsets.

# Which Hypervisor Should I Use?

If you're working solo, then a Type 2 hypervisor like VMware or VirtualBox will allow you to use VMs on your local machine. If you're working in a team, then a Type 1 hypervisor like ESXi or Hyper-V will enable you to run VMs on a dedicated server, and share them with the rest of the team.

## Apple Silicon

For those using modern macOS hardware with Apple Silicon, VirtualBox is the only available option, and only as a developer preview. In addition, it only really supports ARM-based OSes, which means if you're analyzing malware written for x86, you're out of luck. My advice, for those who can afford it, is to use `ESXi` on a dedicated workstation, and access the VMs using the [VMware Remote Console](https://apps.apple.com/us/app/vmware-remote-console/id1230249825). This will allow you to access x86/x64 VMs from your Apple Silicon Mac.