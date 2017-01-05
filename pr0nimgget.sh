#!/bin/bash

PR0NDIR="~/pr0n_img/"


mkdir -p "${PR0NDIR}"

notinarray () {
  local e
  for e in "${@:2}"; do
	if [[ "$e" == "$1" ]]; then
		return 1; 
	fi
  done
  return 0
}

while read line; do
	line="$(echo "$line" | sed "s/\ //g")"
	if echo "$line" | grep -q "^http[s]*://xhamster\.porncache"; then

		if echo "$line" | grep -q "/gallery/"; then
			PR0NTMPNUM="$(echo "$line" | grep -osa "/gallery/[0-9]\+" | sed "s#/gallery/##g")"
			PR0NNEXT="$(wget "$line" -O- --user-agent="Firefox 40" 2>/dev/null | grep -osa "<a href='[^']*/view/$PR0NTMPNUM[^']*" | head -n 1 | sed "s/^<a\ href='//g")"
		else
			PR0NNEXT="$line"
		fi

		echo "Fetching: $PR0NNEXT"
	
		PR0NARR=()
		PR0NNUM="B-O-G-U-S-V-A-L-U-E"
		while notinarray "$PR0NNUM" "${PR0NARR[@]}"; do
			PR0NARR+=("$PR0NNUM")

			PR0NFETCH="$(wget "$PR0NNEXT" -O- --user-agent="Firefox 40" 2>/dev/null)"
			PR0NLINE="$(echo "$PR0NFETCH" | grep 'Click to Next Photo')"
			PR0NIMG="$(echo "$PR0NLINE" | grep -osa "<img\ .*src='[^']*" | sed "s/^<img\ .*src='http/http/g")"

			PR0NNUM="$(echo "$PR0NNEXT" | grep -osa "/view/[0-9]\+-[0-9]\+" | sed "s#/view/##g")"
			PR0NNN="$(echo "$PR0NFETCH" | grep -osa '<title>[^<]*</title>' | sed "s/<[^>]*>//g" | sed "s/\ $//g" | sed "s/\ /_/g" | grep -osa "[0-9A-Za-z\-_+]*" | tr '\n' '-')"

			wget "$PR0NIMG" -O- --user-agent="Firefox 40" 2>/dev/null > "${PR0NDIR}/${PR0NNUM}-${PR0NNN}.jpg"

			PR0NNEXT="$(echo "$PR0NLINE" | grep -osa "<a href='[^']*" | sed "s/^<a\ href='//g")"
			echo "Fetched: ${PR0NNUM}-${PR0NNN}.jpg"
		done
		echo "++++++++++++ Finished ++++++++++++"
	else
		echo "----------- SORRY: UNSUPPORTED URL -----------"
	fi

done
