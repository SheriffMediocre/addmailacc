## Automatically add mail accounts
This script will automatically create an account for a mail server configured with [emailwiz](https://github.com/lukesmithxyz/emailwiz).
It can also add accounts for separate domains configured for the mail server with postfix aliases.

I've written up a guide for setting up secondary domains based off of [this issue](https://github.com/LukeSmithxyz/emailwiz/issues/124).
You will need to add this to your server's configuration *before* you add accounts on secondary domains with this script.
I may or may not script this later on.
Add virtual aliases to /etc/postfix/virtual:

```
@example2.tld user2
@example3.tld user3 # forward mail to from a domain to a specific UNIX user

user2@example.tld user2
user3@example.tld user3 # forward mail - aliased - from a singular domain to multiple UNIX users
```
run postmap /etc/postfix/virtual so postfix will make/utilize a hashtable

Add these lines to /etc/postfix/main.cf:
```
relay_domains = example1.tld, example2.tld, example3.tld...
....
virtual_alias_maps = hash:/etc/postfix/virtual
virtual_alias_domains = $virtual_alias_maps
```

Add these lines to your opendkim configuration
```
/etc/postfix/dkim/keytable:

mail._domainkey.example1.tld example1.tld:mail:/etc/postfix/dkim/example1.tld/mail.private
mail._domainkey.example2.tld example2.tld:mail:/etc/postfix/dkim/example2.tld/mail.private
mail._domainkey.example3.tld example3.tld:mail:/etc/postfix/dkim/example3.tld/mail.private

/etc/postfix/dkim/signingtable

*@example1.tld mail_domainkey.example1.tld
*@example2.tld mail_domainkey.example2.tld
*@example3.tld mail_domainkey.example3.tld

/etc/postfix/dkim/trustedhosts
127.0.0.1
localhost
*.example1.tld
*.example2.tld
*.example3.tld
```


You need to manually generate dkim keys for each subsequent domain you use with the server
```
mkdir -p "/etc/postfix/dkim/example2.tld"
opendkim-genkey -D "/etc/postfix/dkim/example2.tld" -d "example2.tld" -s "mail"
chgrp -R opendkim /etc/postfix/dkim/*
chmod -R g+r /etc/postfix/dkim/*
```
Then you need to grab the keys from ```/etc/postfix/dkim/example2.tld/mail.txt``` and paste it into your registrar's txt records along with the dmarc and spf nonsense.
