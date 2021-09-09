#!/bin/bash
if
	[ "$(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep "browser_download_url" | head -1 | grep -oE "\-([0-9a-f]{8})" | cut -c2-)" = "$(cat ams.short_hash)" ]
then
	echo "No need to publish a new release, exiting..." && exit
else
	echo "Current commit hash does not match the latest release, rebasing..."
	rm ams.short_hash
	rm hbl.version
	rm hbmenu.version
	rm hekate.version
	rm ams.version
	echo "$(curl --silent "https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest" | grep "browser_download_url" | head -1 | grep -oE "\-([0-9a-f]{8})" | cut -c2-)" > ams.short_hash
fi

if
	find out | grep -q $(cat ams.short_hash); then
	echo "Pre-existing build matches latest atmosphere release, nothing needs to be done, exiting..." && exit
else
	echo "Pre-existing build not found/ does not match latest commit"
	rm -rf out
	mkdir out
	echo "$(curl -s "https://api.github.com/repos/switchbrew/nx-hbmenu/releases/latest" | grep "tag_name" | head -1 | cut -c 17-21)" > hbmenu.version
	echo "$(curl -s "https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest" | grep "tag_name" | head -1 | cut -c 16-21)" > ams.version
	echo "$(curl -s "https://api.github.com/repos/CTCaer/hekate/releases/latest" | grep "tag_name" | head -1 | cut -c 17-21)" > hekate.version
	echo "$(curl -s "https://api.github.com/repos/switchbrew/nx-hbloader/releases/latest" | grep "tag_name" | head -1 | cut -c 17-21)" > hbl.version
	mkdir ams
	wget $(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep browser_download_url | head -1 | cut -d '"' -f 4) -O ams/temp.zip
	unzip ams/temp.zip -d ams
	rm ams/temp.zip
	echo "Preparing release archive"
	AMSHASH=`cat ams.short_hash`
	AMSVER=`cat ams.version`
	HBLVER=`cat hbl.version`
	HEKATEVER=`cat hekate.version`
	HBMENUVER=`cat hbmenu.version`
	mkdir hbl
	mkdir hbmenu
	mkdir hekate
	mkdir patches
	mkdir updater
	wget $(curl -s https://api.github.com/repos/switchbrew/nx-hbloader/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) -O hbl/hbl.nsp
	wget $(curl -s https://api.github.com/repos/switchbrew/nx-hbmenu/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) -O hbmenu/temp.zip
	wget $(curl -s https://api.github.com/repos/CTCaer/hekate/releases/latest | grep "browser_download_url" | head -1 | cut -d '"' -f 4) -O hekate/temp.zip
	wget $(curl -s https://api.github.com/repos/ITotalJustice/patches/releases/latest | grep "browser_download_url" | head -1 | cut -d '"' -f 4) -O patches/temp.zip
	unzip hbmenu/temp.zip -d hbmenu
	unzip hekate/temp.zip -d hekate
	unzip patches/temp.zip -d patches
	rm patches/temp.zip
	mkdir ams/atmosphere/hosts
	mkdir ams/atmosphere/config
	cp configs/emummc.txt ams/atmosphere/hosts/emummc.txt
	cp configs/system_settings.ini ams/atmosphere/config/system_settings.ini
	cp hbl/hbl.nsp ams/atmosphere/hbl.nsp
	cp hbmenu/*.nro ams/hbmenu.nro
	cp -r hekate/bootloader ams/
	cp configs/hekate_ipl.ini ams/bootloader/hekate_ipl.ini
	cp ams/atmosphere/reboot_payload.bin ams/bootloader/payloads/fusee.bin
	rm ams/atmosphere/reboot_payload.bin
	cp hekate/*.bin ams/payload.bin
	cp ams/payload.bin ams/atmosphere/reboot_payload.bin
	cp tools/boot.dat ams/boot.dat
	cp tools/boot.ini ams/boot.ini
	mkdir ams/bootloader/res
	cp -r tools/*.bmp ams/bootloader/res/
	cp -r nifm/atmosphere ams/
	cp -r patches/bootloader ams/
	cp -r patches/atmosphere ams/
	cd ams; zip -r ../out/BiteFightOS-${AMSVER}-master-${AMSHASH}+hbl-${HBLVER}+hbmenu-${HBMENUVER}+hekate-${HEKATEVER}+patches.zip ./*; cd ../;
	rm -r hbl
	rm -r hbmenu
	rm -r hekate
	rm -r ams
	rm -r patches
fi

if
	[ -n "$(find "out" -type f -size +4000000c)" ]; then
	echo "Build size passed, continuing"
	echo "Attempting to publish a new build to github"
	res=`curl --user "lsp199308:$(cat gh.token)" -X POST https://api.github.com/repos/lsp199308/BiteFightOS/releases \
	-d "
	{
	  \"tag_name\": \"$(cat ams.version)-$(cat ams.short_hash)\",
	  \"target_commitish\": \"master\",
	  \"name\": \"BiteFightOS $(cat ams.version)-$(cat ams.short_hash)\",
	  \"body\": \"(BiteFightOS)\",
	  \"draft\": false,
	  \"prerelease\": false
	}"`
	echo Create release result: ${res}
	rel_id=`echo ${res} | python -c 'import json,sys;print(json.load(sys.stdin, strict=False)["id"])'`

	curl --user "lsp199308:$(cat gh.token)" -X POST https://uploads.github.com/repos/lsp199308/BiteFightOS/releases/${rel_id}/assets?name=$(ls out | sed -e's/./&\n/g' -e's/ /%20/g' | grep -v '^$' | while read CHAR; do test "${CHAR}" = "%20" && echo "${CHAR}" || echo "${CHAR}" | grep -E '[-[:alnum:]!*.'"'"'()]|\[|\]' || echo -n "${CHAR}" | od -t x1 | tr ' ' '\n' | grep '^[[:alnum:]]\{2\}$' | tr '[a-z]' '[A-Z]' | sed -e's/^/%/g'; done | sed -e's/%20/+/g' | tr -d '\n') --header 'Content-Type: application/zip ' --upload-file out/$(ls out)
	echo "A new build has now been published to github"
else
	echo "Build size is too small a failure has occured!"
	echo "Build failed on $(date)" > log/$(date +%d%B%R).failure
fi
