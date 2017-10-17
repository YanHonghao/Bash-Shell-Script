#!/usr/bin/bash
x=0;
while :
do
	nmcli con show eth${x} &> /dev/null;
	if [ $? -ne 0 ]
	then
		break;
	fi;
	let x=${x}+1;
done;
systemctl status NetworkManager > /dev/null;
if [ $? -ne 0 ]
then
	systemctl restart NetworkManager;
	systemctl enable NetworkManager;
fi;
if=`ip addr|egrep "^2"|gawk -F : '{print $2}'|cut -c 2-`;
ip=`ip addr|egrep "^2"|gawk -F : '{print $2}'|xargs ifconfig|grep "inet\>"|gawk '{print $2}'`/24;
gw=`ip route|gawk 'NR<2{print $3}'`;
nmcli con add con-name eth${x} ifname ${if} type ethernet autoconnect yes ip4 ${ip} gw4 ${gw} ipv4.dns 114.114.114.114;
nmcli con up eth${x};
systemctl restart NetworkManager;
rm -f debug.sh;
