---
title: "20 Know the Enemy"
---

> "If you know the enemy and know yourself, you need not fear the result of a hundred battles." ~Sun Tzu, _The Art of War_

# The Flip-Side

As mentioned in the [Design Section](/0x10 Design/00 Introduction/), malware researchers and malware authors are two sides of the same coin. In this section, we'll explore the analytic methods, techniques and tools used to examine and understand malware samples, and how to perform such analysis safely. As before, this section is not a tutorial, but a reference. There is no single, "correct" way to analyze malware, and the techniques described here are only a subset of those available. I will expand this section over time, and I hope you will contribute, too!

# Primary Objectives

When analyzing malware, there are a few primary objectives you'll aim to achieve:

* Identify the source of the attack. (This is known as "Attribution.")
* Determine the attacker's specific goals.
* Enumerate the steps the attacker took to achieve their goals.
* Document the malware's capabilities and damage potential.
* Design detections and countermeasures to prevent future attacks.

Attackers will do everything in their power to thwart analysis—from obfuscating code to impede analysis, to employing the tactics of other well-known threat actors to muddle attribution. As a result, the analysis process can be difficult and time-consuming. In some cases, full-scale analysis can take weeks or months, with inconclusive results.

The threat landscape evolves at a rapid pace; rather than attempting to perform a full analysis of every new sample, it is better to triage, prioritize, and analyze samples according to their potential impact, postponing lower-priority samples for later analysis.

## Regarding Attribution

When a breach takes place, the first question everyone asks is "Who is responsible?" This is often a difficult question to answer, and it is best to avoid haphazard guesses. Attribution can help defenders understand an adversary; if their strategies are known, defenders can respond accordingly. However, _mis-attribution_ can cause defenders to focus in the wrong places, and can cause trouble when one group takes the blame for another's actions. It is common for advanced threat actors to imitate the behaviors of other threat actors, to muddle attribution.

Rather than focusing heavily on attribution, it is better to ask, "How can we detect and prevent this in the future?" By analyzing how malware functions and propagates, we can reveal attack patterns—and build defenses—which are threat-agnostic. This protects systems against _all_ attackers, not just specific threats.

# Keeping it Safe

Malware analysis is a dangerous business. Malware authors are constantly developing new techniques, not only to thwart analysis, but in some cases, to [damage or infect researchers' systems](https://blog.google/threat-analysis-group/new-campaign-targeting-security-researchers/). It is essential to protect your analysis environment from data loss and infection. The following steps will help you keep your analysis environment safe:

* Maintain a dedicated analysis environment. Do not perform analysis on your production networks and systems. If you must perform analysis in production, ensure that you have clean backups, and if possible, isolate the system from the network to prevent lateral movement.
* Use virtual machines. Virtual machines are a great way to isolate your analysis environment. Ensure that you have a clean snapshot of the VM before you begin analysis, so that you can restore it quickly. If possible, use a disposable VM, such as Google's [Spot VMs](https://cloud.google.com/spot-vms).
* Keep regular, redundant backups of essential data, such as analysis notes and samples. Test backups to ensure they work as expected.
* When interacting with attacker-owned C2 servers, use VPNs or disposable network interfaces. Do not use production networks and interfaces, which could reveal your identity to the attacker.