#!/usr/bin/env bash

GH_USER=borntohonk
GH_PATH=`cat gh.token`
GH_REPO=NeutOS
GH_TARGET=master
ASSETS_PATH=out
AMSHASH=`cat ams.hash`
AMSVER=`cat ams.version`
HBLVER=`cat hbl.version`
HEKATEVER=`cat hekate.version`
HBMENUVER=`cat hbmenu.version`
amsname=`cat ams.name`

res=`curl --user "$GH_USER:$GH_PATH" -X POST https://api.github.com/repos/${GH_USER}/${GH_REPO}/releases \
-d "
{
  \"tag_name\": \"$AMSVER-$(cat ams.hash)\",
  \"target_commitish\": \"$GH_TARGET\",
  \"name\": \"NeutOS $AMSVER-$(cat ams.hash)\",
  \"body\": \"![Banner](https://github.com/borntohonk/NeutOS/raw/neutos/img/banner.png)\r\n**NOTE: AS OF 12.0 NeutOS will no longer support lower FW**\r\nNeutos is maintained for myself.\r\nPlease file an issue with the github issue tracker, if there are any inquiries.\r\nThis github and release is automated, and was published with Suppository ( https://github.com/borntohonk/suppository )\",
  \"draft\": false,
  \"prerelease\": false
}"`
echo Create release result: ${res}
rel_id=`echo ${res} | python -c 'import json,sys;print(json.load(sys.stdin, strict=False)["id"])'`

file_name=$(ls out)
upload_name=$(ls out | sed -e's/./&\n/g' -e's/ /%20/g' | grep -v '^$' | while read CHAR; do test "${CHAR}" = "%20" && echo "${CHAR}" || echo "${CHAR}" | grep -E '[-[:alnum:]!*.'"'"'()]|\[|\]' || echo -n "${CHAR}" | od -t x1 | tr ' ' '\n' | grep '^[[:alnum:]]\{2\}$' | tr '[a-z]' '[A-Z]' | sed -e's/^/%/g'; done | sed -e's/%20/+/g' | tr -d '\n')

curl --user "$GH_USER:$GH_PATH" -X POST https://uploads.github.com/repos/${GH_USER}/${GH_REPO}/releases/${rel_id}/assets?name=${upload_name}\
 --header 'Content-Type: application/zip ' --upload-file ${ASSETS_PATH}/${file_name}
