#!/bin/sh

#this script was written based off information from this github issue: https://github.com/LukeSmithxyz/emailwiz/issues/124

address="$1"

#retrieve the system mail name used during the inital postfix setup
sysmailname=$(cat /etc/mailname)

#the expression "%%@*" means start at the @ symbol, delete it and everything after it
createunixuser() {
useradd -m -G mail ${address%%@*}
passwd ${address%%@*}
}

#if the address entered doesn't use the system mail name add a virtual alias entry
#to direct all mail sent to that address to the appropriate user's mailbox
virtualalias() {
echo "$address ${address%%@*}" >> /etc/postfix/virtual
postmap /etc/postfix/virtual
systemctl reload postfix
}

#check if the address entered contains the system mail name
#the expression "##*@" means start at the @ symbol, delete it and everything in front of it
if [ $sysmailname = ${address##*@} ]; then
	createunixuser
else
	createunixuser
	virtualalias
fi

echo "Successfully added $address!"
