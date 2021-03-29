#!/bin/bash
NEARESTEDGE="ICN"

function time() {
  echo $(($(date +%s%N)/1000000))
}

echo "Getting cloudflare prefix from RADB"
GETPREFIXLIST=`whois -h whois.radb.net -- '-i origin AS13335' | egrep '(^route):' | awk '{print $NF}' | sort -n | uniq`
declare -a PREFIXLISTSORT
for PREFIX in $GETPREFIXLIST
do

	SPLIT=""
	IFS='/'
	read -ra SPLIT <<< "$PREFIX"

	BASEIP=${SPLIT[0]}
    SUBNET=${SPLIT[1]}

	# Field
	PREFIXLISTSORT[${#PREFIXLISTSORT[@]}]="$BASEIP/$SUBNET"

done

IFS=$'\n'
SORTEDPREFIXLIST=`sort -r -k1 <<<${PREFIXLISTSORT[*]}`
unset IFS

echo $SORTEDPREFIXLIST

declare -a FINAL

for PREFIX in $SORTEDPREFIXLIST
do
	SPLIT=""
	IFS='/'
	read -ra SPLIT <<<$PREFIX

	BASEIP=${SPLIT[0]}
	SUBNET=${SPLIT[1]}

	SKIP_CLIENTIP='^8.'
    if [[ $PREFIX =~ ^8. ]]; then
        echo "$BASEIP is not CDN ip. skipping"
        continue
    fi
	
	if [ "$BASEIP" = "1.1.1.0" ] || [ "$BASEIP" = "1.0.0.0" ]; then
		echo "$BASEIP is base ip. skipping"
		continue
	fi

	RESULT=`curl --connect-timeout 1 --max-time 1 "http://${BASEIP}/cdn-cgi/trace" 2> /dev/null`

	if [ $? -eq 0 ]; then
		h=""
		colo=""
		readarray -t <<<$RESULT
		eval ${MAPFILE[1]}
		eval ${MAPFILE[6]}
		if [ $h = $BASEIP ]; then
			echo "$BASEIP is CDN ip"

			if [ "$colo" != "$NEARESTEDGE" ]; then
				echo "$BASEIP/$SUBNET($colo) WILL BE AFFECT!"
				FINAL[${#FINAL[@]}]="$BASEIP/$SUBNET"
			fi

		else
			echo "$BASEIP is not CDN ip. (FAIL RESULT)"
		fi
	else
		echo "$BASEIP is not CDN ip."
	fi

done

IFS=$'\n'

cat > outputprefix.txt <<<${FINAL[*]}
