---
title: "10 Let's Write Some Malware!"
---

> “With how many things are we on the brink of becoming acquainted, if cowardice or carelessness did not restrain our inquiries?” ~Mary Shelley, _Frankenstein_

# Wait... Really?

Absolutely! To be a successful malware researcher, one must understand malware design. Likewise, every successful malware designer must also be a researcher. The two are inextricable; the only distinction between analysts and adversaries is how they apply their knowledge and skill. Do they help others, or do they harm them?

I'm in the "help others" camp; I hope you are, too. One cannot defeat what one does not understand. The best way to understand malware is to design your own.

The following sections will provide an overview of a variety of malware design techniques. They are a reference, not a tutorial, and do not follow a linear trajectory. This repository will grow during the course of my research, as I document new discoveries. I hope you will contribute, too! If you have a technique you'd like to share, please open an issue or pull request on GitHub.

# Isn't this illegal?

[Good question!](https://www.oreilly.com/library/view/malicious-mobile-code/156592682X/ch01s03.html) To start, let me say **I am not a lawyer, and you should consult your local laws before writing, compiling, or distributing malware.** I am not responsible for any legal consequences you may face as a result of your actions.

That said, there are countless malware researchers and red-team operators who have written, compiled, and deployed malware without any legal repercussions. [Some people even sell their malware as a commercial product!](https://www.cobaltstrike.com/)

Generally speaking, designing and documenting malicious source code is safe, especially within the context of research. Compiling the code into live malware samples is also (relatively) safe, as long as the samples are kept in quarantine or deployed under controlled conditions to systems you personally own, or those to which you have explicit permission to deploy malware.

They key here is consent. The moment your malware runs on a system without the owner's consent, you have crossed the line into criminal activity, even if the malware causes no real harm. **If you are unsure about the legality of your actions, consult a lawyer.**

# That said...

This site will not provide the complete source code for any malware samples. Instead, we will provide code snippets focused on demonstrating specific techniques. This is for two reasons: first, snippets are easier to understand than full programs; second, we don't want to provide skids with easy fodder. If you want to write malware, you'll have to do the hard work yourself. (Or check out one of the pre-made, open-source frameworks, like [Metasploit](https://github.com/rapid7/metasploit-framework), [Veil](https://github.com/Veil-Framework/Veil), or [Empire](https://github.com/EmpireProject/Empire).)