#!/bin/bash
if
	[ "$(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep "browser_download_url" | head -1 | grep -oE "\-([0-9a-f]{8})" | cut -c2-)" = "$(cat ams.hash)" ]
then
	echo "No need to publish a new release, exiting..." && exit
else
	echo "Current commit hash does not match the latest release, rebasing..."
	rm ams.hash
	rm hbl.version
	rm hbmenu.version
	rm hekate.version
	rm ams.version
	echo "$(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep "browser_download_url" | head -1 | grep -oE "\-([0-9a-f]{8})" | cut -c2-)" > ams.hash
fi

	rm -rf out
	mkdir out
	echo "$(curl -s "https://api.github.com/repos/switchbrew/nx-hbmenu/releases/latest" | grep "tag_name" | head -1 | cut -c 17-21)" > hbmenu.version
	echo "$(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep "tag_name" | head -1 | cut -c 16-21)" > ams.version
	echo "$(curl -s "https://api.github.com/repos/CTCaer/hekate/releases/latest" | grep "tag_name" | head -1 | cut -c 17-21)" > hekate.version
	echo "$(curl -s "https://api.github.com/repos/switchbrew/nx-hbloader/releases/latest" | grep "tag_name" | head -1 | cut -c 17-21)" > hbl.version
	mkdir ams
	wget $(curl -s https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases/latest | grep browser_download_url | head -1 | cut -d '"' -f 4) -O ams/temp.zip
	unzip ams/temp.zip -d ams
	rm ams/temp.zip
	mkdir ams/atmosphere/kip_patches/loader_patches
	echo "Putting togheter the release archive"
	cd tools
	rm -rf extracted
	mkdir extracted
	python3 extract.py
	sleep 1
	./hactool --intype=kip1 --uncompressed=extracted/Loader-dec.kip extracted/Loader.kip
	sleep 1
	python3 patch.py
	sleep 1
	rm -rf extracted
	sleep 1
	cd ..
	mkdir hbl
	mkdir hbmenu
	mkdir hekate
	wget $(curl -s https://api.github.com/repos/switchbrew/nx-hbloader/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) -O hbl/hbl.nsp
	wget $(curl -s https://api.github.com/repos/switchbrew/nx-hbmenu/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) -O hbmenu/temp.zip
	wget $(curl -s https://api.github.com/repos/CTCaer/hekate/releases/latest | grep "browser_download_url" | head -1 | cut -d '"' -f 4) -O hekate/temp.zip
	unzip hbmenu/temp.zip -d hbmenu
	unzip hekate/temp.zip -d hekate
	cp configs/exosphere.ini ams/exosphere.ini
	mkdir ams/atmosphere/hosts
	cp configs/emummc.txt ams/atmosphere/hosts/emummc.txt
	cp configs/sysmmc.txt ams/atmosphere/hosts/sysmmc.txt
	cp hbl/hbl.nsp ams/atmosphere/hbl.nsp
	cp hbmenu/hbmenu.nro ams/hbmenu.nro
	cp -r hekate/bootloader ams/
	cp configs/hekate_ipl.ini ams/bootloader/hekate_ipl.ini
	cp ams/atmosphere/reboot_payload.bin ams/bootloader/payloads/fusee-primary.bin
	rm ams/atmosphere/reboot_payload.bin
	cp hekate/*.bin ams/payload.bin
	cp ams/payload.bin ams/atmosphere/reboot_payload.bin
	cp -r patches/kip_patches ams/atmosphere
	cp -r patches/exefs_patches ams/atmosphere
	AMSHASH=`cat ams.hash`
	AMSVER=`cat ams.version`
	HBLVER=`cat hbl.version`
	HEKATEVER=`cat hekate.version`
	HBMENUVER=`cat hbmenu.version`
	cd ams; zip -r ../out/NeutOS-${AMSVER}-master-${AMSHASH}+hbl-${HBLVER}+hbmenu-${HBMENUVER}+hekate-${HEKATEVER}+patches.zip ./*; cd ../;
	rm -r hbl
	rm -r hbmenu
	rm -r hekate
	rm -r ams
	mkdir log
if
	[ -n "$(find "out" -type f -size +4000000c)" ]; then
	echo "Build size passed, continuing"
	echo "Attempting to publish a new build to github"
	res=`curl --user "borntohonk:$(cat gh.token)" -X POST https://api.github.com/repos/borntohonk/NeutOS/releases \
	-d "
	{
	  \"tag_name\": \"$(cat ams.version)-$(cat ams.hash)\",
	  \"target_commitish\": \"master\",
	  \"name\": \"NeutOS $(cat ams.version)-$(cat ams.hash)\",
	  \"body\": \"![Banner](https://github.com/borntohonk/NeutOS/raw/neutos/img/banner.png)\r\n**NOTE: AS OF 12.0 NeutOS will no longer support lower FW**\r\nNeutos is maintained for myself.\r\nPlease file an issue with the github issue tracker, if there are any inquiries.\r\nThis github and release is automated, and was published with suppository ( https://github.com/borntohonk/suppository )\",
	  \"draft\": false,
	  \"prerelease\": false
	}"`
	echo Create release result: ${res}
	rel_id=`echo ${res} | python -c 'import json,sys;print(json.load(sys.stdin, strict=False)["id"])'`

	curl --user "borntohonk:$(cat gh.token)" -X POST https://uploads.github.com/repos/borntohonk/NeutOS/releases/${rel_id}/assets?name=$(ls out | sed -e's/./&\n/g' -e's/ /%20/g' | grep -v '^$' | while read CHAR; do test "${CHAR}" = "%20" && echo "${CHAR}" || echo "${CHAR}" | grep -E '[-[:alnum:]!*.'"'"'()]|\[|\]' || echo -n "${CHAR}" | od -t x1 | tr ' ' '\n' | grep '^[[:alnum:]]\{2\}$' | tr '[a-z]' '[A-Z]' | sed -e's/^/%/g'; done | sed -e's/%20/+/g' | tr -d '\n') --header 'Content-Type: application/zip ' --upload-file out/$(ls out)
	echo "A new build has now been published to github"
	echo "Build was completed with success on $(date)" > log/$(date +%d%B%R).success
else
	echo "Build size is too small a failure has occured!"
	echo "Build failed on $(date)" > log/$(date +%d%B%R).failure
fi
