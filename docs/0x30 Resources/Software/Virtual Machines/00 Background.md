---
title: "A Little VM History"
---

# Back in My Day...

Used to be, if you wanted to try out a new OS, you'd have to install it on "bare metal." If you didn't have a spare PC, you'd wipe your old OS to try the new one. And if you didn't like the new OS? You'd re-install the old one, and have to re-install all your apps, re-configure all your settings... What a hassle.

# Jeckyll and Hyde

Some systems could "[multi-boot](https://en.wikipedia.org/wiki/Multi-booting)," allowing for multiple OSes on a single machine. This was great for people who wanted to explore new OSes without losing their dependable OS, or for people who needed to use tools available on different OSes. There were still some problems:

* Only one OS could run at a time.
* Every OS had access to every other OS; if malware ran in one OS, it could infect all the rest.

# We're Doing It Live

The Live CD was revolutionary, allowing OSes to be run from read-only CD drives without the need for installation. The first few were pretty niche, but systems like [Knoppix](https://www.knopper.net/knoppix/index-en.html) and [Slax](https://www.slax.org/) changed the game, providing a full-featured Linux OS on a Live CD. One notable example was [BackTrack](https://www.backtrack-linux.org/), a Linux Live CD designed for penetration testing. In 2013, [Offensive Security](https://www.offensive-security.com/) rebased BackTrack on Debian instead of Ubuntu, and changed its name to [Kali Linux](https://www.kali.org/). Kali has become the de-facto standard for the industry.

Live CDs made for great [recovery OSes](https://en.wikipedia.org/wiki/BartPE), and could even be configured to provide [anonymity and privacy](https://tails.boum.org/). But they still had some problems:

* They were read-only, so you couldn't install anything permanently without a secondary storage medium.
* They were slow, because they had to read from the CD drive.

These days, people are more likely to use a Live USB drive than a Live CD, but they work in basically the same way.

# Yo Dawg, I Herd You Like Computers

As computers got faster, it became possible to run multiple OSes simultaneously, through a process called [virtualization](https://en.wikipedia.org/wiki/Virtualization). In this process, a single "host" OS runs a "hypervisor" that manages one or more "guest" OSes. The guest OSes are isolated from each other, and from the host OS. This allows for a lot of flexibility; for example, if you want to analyze a malware sample safely, you could spin up a temporary Windows VM in an isolated network, ensuring that it cannot spread to other systems, while simultaneously taking analysis notes on the host OS or a separate VM.

VMs offer many advantages over Live CDs, such as:

* Multiple OSes can be run simultaneously on a single host.
* Systems can quickly and easily be restored to a known good state.
* VMs are isolated from the host and from each other.
* Multiple virtualized networks can be configured between guests on a single machine.
* VMs can be cloned and moved between machines.
* VMs can be run on cloud services, reducing the need for expensive local hardware and complicated upkeep.

# Which is Best?

For the purposes of malware design and analysis, we advise the use of VMs over Live CDs/USBs, dual-booting, and full-disk installs, as they offer the most flexibility and control. However, there are some reasons and situations for which Live CDs/USBs are preferable:

* Some systems, such as macOS, cannot easily be virtualized.
* Live CDs/USBs are better-suited for forensic analysis of physical hardware, such as infected hard drives.
* Some specialized hardware cannot easily be eulated or passed through to a VM.