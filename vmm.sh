#!/usr/bin/bash
if test ! -e /var/lib/libvirt/images/CentOS7.4-Base.qcow2
then
	rpm -q wget qemu-kvm qemu-img libvirt libvirt-client virt-manager > /dev/null;
	if [ $? -ne 0 ]
	then
		yum -y install wget qemu-kvm qemu-img libvirt libvirt-client virt-manager;
	fi;
	ping 47.94.208.160 -c 1 -W 1;
	if [ $? -ne 0 ]
	then
		echo "Error:> Cannot connect to 47.94.208.160.";
		exit;
	fi;
	wget --no-passive-ftp -O /var/lib/libvirt/images/CentOS7.4-Base.qcow2 ftp://47.94.208.160/CentOS7.4/CentOS7.4-Base.qcow2;
	wget --no-passive-ftp -O /etc/libvirt/qemu/CentOS7.4-Base ftp://47.94.208.160/CentOS7.4/CentOS7.4-Base;
	cp /etc/libvirt/qemu/CentOS7.4-Base /etc/libvirt/qemu/CentOS7.4-Base.xml
	systemctl restart libvirtd;
	systemctl enable libvirtd;
fi;
systemctl status libvirtd > /dev/null;
if [ $? -ne 0 ]
then
	systemctl start libvirtd;
	systemctl enable libvirtd;
fi;
if [[ "${1}" =~ ^[[:digit:]]+$ ]]
then
	if [ ${1} -ne 0 ]
	then
		for x in `seq ${1}`
		do
			virsh list | grep "CentOS7.4-Auto-${x}";
			if [ $? -eq 0 ]
			then
			virsh destroy CentOS7.4-Auto-${x};
			fi;
			virsh list --all | grep "CentOS7.4-Auto-${x}";
			if [ $? -eq 0 ]
			then
			virsh undefine CentOS7.4-Auto-${x} --remove-all-storage;
			fi;
			qemu-img create -b /var/lib/libvirt/images/CentOS7.4-Base.qcow2 -f qcow2 /var/lib/libvirt/images/CentOS7.4-Auto-${x}.qcow2;
			cp /etc/libvirt/qemu/CentOS7.4-Base /etc/libvirt/qemu/CentOS7.4-Auto-${x}.xml;
			sed -i -r "s/CentOS7.4-Origin/CentOS7.4-Auto-${x}/" /etc/libvirt/qemu/CentOS7.4-Auto-${x}.xml;
			virsh define /etc/libvirt/qemu/CentOS7.4-Auto-${x}.xml;
		done;
	else
		for x in `virsh list --all | gawk 'NR>2{print $2}' | grep "CentOS7.4-Auto-"`
		do
			virsh list | grep "${x}";
			if [ $? -eq 0 ]
			then
			virsh destroy ${x};
			fi;
			virsh undefine ${x} --remove-all-storage;
		done;
	fi;
	systemctl restart libvirtd;
	exit;
fi;
virsh list --all;
while :
do
	read -p "Command:> " x;
	if [[ ! "${x}" =~ ^-?[[:digit:]]+$ ]]
	then
		echo "Warning:> Error command.";
		continue;
	elif [ ${x} -gt 0 ]
	then
		virsh list | grep "CentOS7.4-${x}"
		if [ $? -eq 0 ]
		then
			virsh destroy CentOS7.4-${x};
		fi;
		virsh list --all | grep "CentOS7.4-${x}";
		if [ $? -eq 0 ]
		then
			virsh undefine CentOS7.4-${x} --remove-all-storage;
		fi;
		qemu-img create -b /var/lib/libvirt/images/CentOS7.4-Base.qcow2 -f qcow2 /var/lib/libvirt/images/CentOS7.4-${x}.qcow2;
		cp /etc/libvirt/qemu/CentOS7.4-Base /etc/libvirt/qemu/CentOS7.4-${x}.xml;
		sed -i -r "s/CentOS7.4-Base/CentOS7.4-${x}/" /etc/libvirt/qemu/CentOS7.4-${x}.xml;
		virsh define /etc/libvirt/qemu/CentOS7.4-${x}.xml;
	elif [ ${x} -eq 0 ]
	then
		if [ "${x}" != "-0" ]
		then
			for x in `virsh list --all | gawk 'NR>2{print $2}' | egrep "^CentOS7.4-[[:digit:]]+$"`
			do
				virsh list | grep "${x}";
				if [ $? -eq 0 ]
				then
				virsh destroy ${x};
				fi;
				virsh undefine ${x} --remove-all-storage;
			done;
		else
			for x in `virsh list --all | gawk 'NR>2{print $2}'`
			do
				virsh list | grep "${x}";
				if [ $? -eq 0 ]
				then
				virsh destroy ${x};
				fi;
				virsh undefine ${x} --remove-all-storage;
			done;
			rm -f /etc/libvirt/qemu/CentOS7.4-Base;
			exit;
		fi;
	else
		let x=${x}*-1;	
		virsh list | grep "CentOS7.4-${x}"
		if [ $? -eq 0 ]
		then
			virsh destroy CentOS7.4-${x};
		fi;
		virsh list --all | grep "CentOS7.4-${x}";
		if [ $? -eq 0 ]
		then
			virsh undefine CentOS7.4-${x} --remove-all-storage;
		fi;
	fi;
	systemctl restart libvirtd;
	virsh list --all;
done;
