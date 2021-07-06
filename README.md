This version of suppository comes configured for use in a freeBSD jail, and comes with a hactool binary for freeBSD. 

This version of suppository will automatically download the latest version of atmosphere, if there is a new version, generate a "loader" ips patch, bundle desired files, then automatically publish it to github.

If you have any inquiries; file an issue with the github tracker.

Suppository was configured to only have patch sets for FW 12.0.0 and up, pruning older versions after it became apparant that the patcher api within atmosphere became overloaded with patches, making boots become inconsistent as of 12th of april 2021.

how to obtain: git clone https://github.com/borntohonk/suppository.git

how to use: sh check.sh (add to crontab for maximum effect)

This repository is called suppository. It's primary purpose is to repackage and publish a bundled version of atmosphere bundle for my own personal use.

For publishing you're going to want to put your github api personal token under gh.token in the git clone directory.

pre-requisites: 
* must be able to use a text-editor (at very least) to make alterations to deploy other forks. 
* be on a freeBSD based system and using jail functionality.
* have python3 installed in the jail

---
credits: me (@borntohonk)
license: whichever applicable to whichever files and MIT on whatever else (not that there's anything worth licensing here)
