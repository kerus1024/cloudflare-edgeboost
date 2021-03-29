#!/bin/bash
TARGET="1.0.0.1"

if [ ! -f ./outputprefix.txt ]; then
	echo "File not found!"
	echo "Run findtarget.bash first."
	exit 1
fi

iptables -D OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -I OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

IFS=$'\r\n' GLOBIGNORE='*' command eval  'PREFIXLIST=($(cat ./outputprefix.txt))'

for PREFIX in ${PREFIXLIST[*]}
do

	echo "Setup $PREFIX"

	if [ "$1" = "down" ]; then
  		echo "DELETE CHAIN"
		iptables -t nat -D OUTPUT --destination $PREFIX -j DNAT --to-destination=$TARGET
	else
		iptables -t nat -A OUTPUT --destination $PREFIX -j DNAT --to-destination=$TARGET
	fi

done

