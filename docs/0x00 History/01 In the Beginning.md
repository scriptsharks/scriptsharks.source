---
title: "01 In the Beginning..."
---

> "I couldn't help thinking how well Cain had prospered after killing his brother: he founded the first city—and, although we don't like to talk about it all that much, we are his children." ~Philip Gourevitch, _We Wish to Inform You That Tomorrow We Will Be Killed with Our Families_

# Dawn of an Age

Long ago, when people wanted to count things, they had to use their fingers. For bigger numbers, they had to use their toes, too, or even borrow the fingers and toes of their neighbors. But this was untenable, so people started carving tallies into sticks and bones. In 2400 BCE, the Babylonians invented what would become the abacus. Around 100 BCE, the [Antikythera Mechanism](https://en.wikipedia.org/wiki/Antikythera_mechanism), the oldest example of an analogue computer, was used to predict astronomical events. These humble beginnings triggered humanity's undying hunger for technological advancement, which became the guiding principle behind the current "smart everything" era.

In their defense, those ancient inventors couldn't have predicted ransomware when they were pushing beads about strings and building tools to track the stars. If you don't keep [regular backups of essential data](https://www.google.com/search?q=3-2-1+backup+rule), don't go blaming Babylon when an email attachment wipes your drives.

# Yes, _That_ von Neumann

In 1949, [John von Neumann](https://en.wikipedia.org/wiki/John_von_Neumann) gave a series of lectures about the "Theory and Organization of Complicated Automata," which became the basis for his ["Theory of Self-Reproducing Automata"](http://cba.mit.edu/events/03.11.ASE/docs/VonNeumann.pdf), published in 1966. During his lifetime, von Neumann wrote over 150 papers about mathematics, physics and computing, contributed to the [Manhattan Project](https://en.wikipedia.org/wiki/Manhattan_Project) during World War II, and promoted the policy of [mutually assured destruction](https://en.wikipedia.org/wiki/Mutual_assured_destruction) to deter the nuclear arms race.

In retrospect, von Neumann's 1966 article may seem one of his less-notable achievements. Yet this paper contributed directly to the invention of the earliest examples of malicious software (the term "malware" wasn't coined until the '90s, over 20 years following von Neumann's paper).

# Creeper and Reaper

In 1971, Bob Thomas wrote [Creeper](https://en.wikipedia.org/wiki/Creeper_(program)), a program designed to test the ideas proposed by von Neumann's article. Creeper migrated across [PDP-10](https://en.wikipedia.org/wiki/PDP-10) mainframes running [TENEX](https://en.wikipedia.org/wiki/TENEX_(operating_system)) which were connected to [ARPANET](https://en.wikipedia.org/wiki/ARPANET). Systems infected by Creeper would show the message "I'M THE CREEPER; CATCH ME IF YOU CAN" before the malware jumped to a different system on the network.

A second variant of Creeper produced by Ray Tomlinson was altered so that instead of moving itself between systems, it would duplicate itself across systems, thus becoming the world's first computer worm. Recognizing the evil he had brought into the world, Tomlinson attempted to re-balance his karmic scales by producing [Reaper](https://en.wikipedia.org/wiki/Reaper_(program)), a program designed to seek out and destroy the Creeper worm.

Unfortunately, Reaper functioned much like Creeper, spreading across PDP-10s on ARPANET. Thus, despite being the world's first anti-virus software, it also became the world's second computer worm, and the first example of software fratricide.

Like Cain slaying Abel, the conflict between Reaper and Creeper set the stage for the present-day digital arms race, pitting malware authors against antivirus engineers in a never-ending battle for supremacy.

Speaking of battles for digital supremacy, Creeper and Reaper also inspired the creation of [Core War](https://en.wikipedia.org/wiki/Core_War) in 1984, a computer programming game wherein software "warriors" fight for dominance in a virtual computer. Warrior programs were written in "Redcode," a primitive form of Assembly Language designed specifically for the game.

Fictionalized versions of Reaper also featured as antagonists in the Japanese anime TV series [Digimon](https://en.wikipedia.org/wiki/Digimon_Tamers). So cool.

# Wascally Wabbits

The first [fork bomb](https://en.wikipedia.org/wiki/Fork_bomb) dropped in 1974 in the form of "Wabbit" (or "Rabbit," depending on who you ask). The program would "fork" itself in memory ad infinitum, draining resources until the affected systems ground to a halt. The malware earned its name from the rate at which the program reproduced.

Fun trivia: A similar fork bomb plays a significant role in ScriptSharks history! (But that's a story for a different time.)

# Think of an Animal...

In 1975, John Walker created the first [Trojan Horse](https://en.wikipedia.org/wiki/Trojan_horse_(computing)) malware as a mechanism for distributing a video game he had designed. The game was called ANIMAL, and was quite the clever iteration upon the old "guess the animal" games of the day. John's ANIMAL script included a bunch of nifty tricks that drew inspiration from [ELIZA](https://en.wikipedia.org/wiki/ELIZA) to present a more life-like, adaptive experience. The game was quite popular, and everyone wanted a copy. Rather than write the program to a bunch of drives and shipping them to all his buddies, John took a more creative approach. He created a subroutine, called PERVADE, which ran in the background as users were playing the game. The PERVADE subroutine would scan the system for accessible directories, checking to see whether a copy of ANIMAL existed in that directory. If not, PERVADE would create a copy of the game in that directory. Otherwise, it would check to see if the running version was newer than the saved copy, replacing older versions with newer ones. The trojan spread through the system, gaining greater access as more powerful users played the game. In time, it spread to external media, thus spreading to other systems.

Within a month of its release, ANIMAL had spread across numerous [Univac](https://en.wikipedia.org/wiki/Univac) computers, eventually making its way to Univac's software development center in Minnesota. Rumor has it, Univac (the organization) inadvertently shipped software distribution tapes which contained ANIMAL. If true, this could be the first instance of a [supply-chain attack](https://en.wikipedia.org/wiki/Supply_chain_attack) (though it was, admittedly, unintentional).

After recognizing how wide-spread ANIMAL had become, John and his associates considered how they might go about cleaning up the ANIMAL mess. They brainstormed, considered releasing a HUNTER program to spread and destroy the ANIMALs (much like Reaper before it), but in the end the problem was solved without any intervention necessary; Univac released a new Operating System, which handled filesystems in a slightly different manner. The change was minor, but it was enough to break the PERVADE subroutine, thus rendering ANIMAL toothless.

# End of the Beginning

These stories are legends, indicative of the playful nature of early hackers. Many of the "Old Guard" reminisce about this era, when hackers were clever pranksters, driven by passion rather than malice. Alas, nothing lasts, and the 1980s witnessed an explosion of the first truly malicious malware in history.