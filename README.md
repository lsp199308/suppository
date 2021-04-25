If you have any inquiries; file an issue with the github tracker.

Suppository was configured to only have patch sets for FW 12.0.0 and up, pruning older versions after it became apparant that the patcher api within atmosphere became overloaded with patches, making boots become inconsistent as of 12th of april 2021.

how to obtain: git clone https://github.com/borntohonk/suppository.git --recurse-submodules

how to use: sh check.sh

check.sh will check if there's a need to rebase, and if there is a reason to, it will rebase against the commit declared in the filename of the latest release from Atmosphere-NX/Atmosphere, then check the hash of the locally built file to see if it matches the forks hash; do nothing if it matches; re-build if it doesn't match and then attempt to run publish.sh which will publish an automated release. (scenarios where it might not match include: new Atmosphere-NX/Atmosphere release, or a "stealth-update")

It currently will automatically rebase, then build and publish a release of the fork it's targeting, if needed utilizing the github api.

This repository is called suppository. It's primary purpose is to build and publish an altered version of atmosphere bundle for my own personal use.

You can fork suppository and alter the values defined in check.sh, build.sh and publish.sh to make adjustments. (and obviously the submodule)

For publishing you're going to want to put your github api personal token under .ghtoken and have it set up as GH_TOKEN_PATH in i.e. .bashrc

example .bashrc config
---

- export SEPT_SECONDARY_BIN_PATH=~/sept/sept-secondary.bin
- export SEPT_00_ENC_PATH=~/sept/sept-secondary_00.enc
- export SEPT_01_ENC_PATH=~/sept/sept-secondary_01.enc
- export SEPT_DEV_00_ENC_PATH=~/sept/sept-secondary_dev_00.enc
- export SEPT_DEV_01_ENC_PATH=~/sept/sept-secondary_dev_01.enc
- export GH_TOKEN_PATH=~/.ghtoken

---

pre-requisites: 
* must atleast be able to compile Atmosphere
* must be able to use a text-editor (at very least) to make alterations to deploy other forks. 
* maybe be on linux, not that I care if you aren't.
* have a path for "SEPT_SECONDARY_BIN_PATH" similar to that of the path for the .enc's that atmosphere require for building (this done to have people not nag about sept-secondary.bin being 0kb despite it not being used by atmosphere at all)
* have a path for "GH_TOKEN_PATH", with the contents of your github api token, with permissions for managing repositories.

---
credits: me (@borntohonk)
license: whichever applicable to whichever files and MIT on whatever else (not that there's anything worth licensing here)
