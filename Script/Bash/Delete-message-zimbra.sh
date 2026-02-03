#!/bin/bash
# rm_message.sh user@domain.com subject
# create temp_file prior to calling this zmprov -l gaa | grep domain.com > /tmp/temp_email

# zmmailbox -z -m username@example.com s -t message -l 1000 "in:Inbox subject: SELAMAT KAMU DAPAT PENGHASILAN TAMBAHAN "

for acct in `su - zimbra -c 'zmprov -l gaa |grep "@mcf.co.id"| sort'`; do
#for acct in `su - zimbra -c 'zmprov -l gaa | sort'`; do
echo "Addr" : $acct
#for msg in `/opt/zimbra/bin/zmmailbox -z -m "$acct" s -l 999 -t message "from:ad.wind2@spam.bd" |awk '{ if (NR!=1) {print}}' | grep -v -e Id -e "-" -e "^$" | awk '{ print $2 }'`
for msg in `/opt/zimbra/bin/zmmailbox -z -m "$acct" s -t message -l 1000 "in:Inbox subject: SELAMAT KAMU DAPAT PENGHASILAN TAMBAHAN" |awk '{ if (NR!=1) {print}}' | grep -v -e Id -e "-" -e "^$" | awk '{ print $2 }'`
do
echo "Removing "$msg" from "$acct"" >> /tmp/logmcf.txt
/opt/zimbra/bin/zmmailbox -z -m $acct dm $msg
done
done


root@zmbox1:/tmp# nohup sh rm_message-maf.sh &
[1] 8769
root@zmbox1:/tmp# nohup: ignoring input and appending output to 'nohup.out'

root@zmbox1:/tmp# nohup sh rm_message-mcf.sh &
[2] 13986
root@zmbox1:/tmp# nohup: ignoring input and appending output to 'nohup.out'

root@zmbox1:/tmp#

