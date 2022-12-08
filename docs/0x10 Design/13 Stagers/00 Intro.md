---
title: "Stager Basics"
---

# What's a Stager?

A stager is a short script or binary designed to install a larger piece of malware on a target system. Stagers are often packaged with droppers, but may exist on their own.

## Core Features

Much like droppers, stagers should be small, self-contained and non-malicious, and should run without administrative privileges. They should also be decoupled from droppers and payloads, so that components can be replaced with minimal effort. In addition, if elevated privileges are requires, stagers should handle privilege escalation prior to installing their bundled payload.

[wip]