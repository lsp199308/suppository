#!/bin/bash
if
	[ "$(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep "browser_download_url.*zip" | head -1 | grep -oE "\-([0-9a-f]{8})" | cut -c2-)" = "$(cat ams.hash)" ]
then
	echo "No need to rebase, exiting..." && exit
else
	echo "Current commit hash does not match, rebasing..."
	rm ams.hash
	rm hbl.version
	rm hbmenu.version
	rm ams.changelog
	rm ams.name
	rm hekate.version
	rm ams.version
	echo "$(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep "browser_download_url.*zip" | head -1 | grep -oE "\-([0-9a-f]{8})" | cut -c2-)" > ams.hash
fi

	echo "Pre-existing build not found/ does not match latest commit, building..."
	rm -rf out
	mkdir out
	echo "$(curl -s "https://api.github.com/repos/switchbrew/nx-hbmenu/releases/latest" | grep "tag_name" | head -1 | cut -c 17-21)" > hbmenu.version
	echo "$(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep "tag_name" | head -1 | cut -c 16-21)" > ams.version
	echo "$(curl -s "https://api.github.com/repos/CTCaer/hekate/releases/latest" | grep "tag_name" | head -1 | cut -c 17-21)" > hekate.version
	echo "$(curl -s "https://api.github.com/repos/switchbrew/nx-hbloader/releases/latest" | grep "tag_name" | head -1 | cut -c 17-21)" > hbl.version
	curl -s "https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest" | grep body | head -1 | cut -c 12->ams.changelog
	sed -i 's/.$//' ams.changelog
	mkdir ams
	echo "$(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep "browser_download_url.*zip" | cut -d : -f 2,3 | head -1 | tr -d \" | sed 's/.*\///' | sed 's/%2B/+/g')" > ams.name
	wget $(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest  | grep browser_download_url | grep '[.]zip' | head -n 1 | cut -d '"' -f 4) -O ams/temp.zip
	unzip ams/temp.zip -d ams
	rm ams/temp.zip
	mkdir ams/atmosphere/kip_patches/loader_patches
	echo "Putting togheter the release archive"
	cd tools
	sh extract.sh
	cd ..
	mkdir hbl
	mkdir hbmenu
	mkdir hekate
	wget $(curl -s https://api.github.com/repos/switchbrew/nx-hbloader/releases/latest | grep browser_download_url | cut -d '"' -f 4) -O hbl/hbl.nsp
	wget $(curl -s https://api.github.com/repos/switchbrew/nx-hbmenu/releases/latest | grep browser_download_url | cut -d '"' -f 4) -O hbmenu/temp.zip
	wget $(curl -s https://api.github.com/repos/CTCaer/hekate/releases/latest | grep browser_download_url | head -1 | cut -d '"' -f 4) -O hekate/temp.zip
	cp configs/exosphere.ini ams/exosphere.ini
	sh build.sh

if
	[ -n "$(find "out" -type f -size +4000000c)" ]; then
	echo "Build size passed, continuing"
	echo "Attempting to publish a new build to github" && sh publish.sh
	echo "A new build has now been published to github"
	echo "Build was completed with success on $(date)" > log/$(date +%d%B%R).success
else
	echo "Build size is too small a failure has occured!"
	echo "Build failed on $(date)" > log/$(date +%d%B%R).failure
fi
