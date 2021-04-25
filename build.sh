#!/bin/bash
HBLVER=$(cat hbl.version)
HBMENUVER=$(cat hbmenu.version)
HEKATEVER=$(cat hekate.version)
OUTPUTHASH=$(cat ams.hash)
AMSNAME=$(cat ams.name)
OUTPUTREV="master-$OUTPUTHASH"
OUTPUTVER="$(cat ams.version)-$OUTPUTREV"
	unzip hbmenu/temp.zip -d hbmenu
	unzip hekate/temp.zip -d hekate
	cp configs/exosphere.ini ams/exosphere.ini
	mkdir ams/atmosphere/hosts
	cp configs/emummc.txt ams/atmosphere/hosts/emummc.txt
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
	cd ams; zip -r ../$AMSNAME ./*; cd ../;
	rm -r hbl
	rm -r hbmenu
	rm -r hekate
	rm -r ams
	mv $AMSNAME out/NeutOS-$OUTPUTVER+hbl-$HBLVER+hbmenu-$HBMENUVER+hekate-$HEKATEVER+patches.zip
