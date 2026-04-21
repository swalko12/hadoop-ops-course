#!/bin/bash

set -ex

INSTANCES="bigtop_hostname0 bigtop_hostname1 bigtop_hostname2 bigtop_hostname3"
INSTANCES_WITHOUT_0="bigtop_hostname1 bigtop_hostname2 bigtop_hostname3"

for i in $INSTANCES ; do
	if [ $(${CMD} ps |grep -c $i) == "0" ] ; then
		echo "can't find docker container: $i"
		exit 1
	fi
done

for i in $INSTANCES ; do
	${CMD} exec -it $i dnf install -y sudo openssh-server openssh-clients which iproute net-tools less vim-enhanced initscripts wget curl tar unzip git dnf-plugins-core
	${CMD} exec -it $i dnf config-manager --set-enabled powertools
	${CMD} exec -it $i dnf update -y || echo "update failed, but continuing"
done

for i in $INSTANCES ; do
	${CMD} exec -it $i ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
	
	# Start SSH service
	${CMD} exec -it $i systemctl enable sshd
	${CMD} exec -it $i systemctl start sshd
done

for i in $INSTANCES ; do
	${CMD} exec -it $i setenforce 0 || echo "selinux is disabled"
	${CMD} exec -it $i sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/Rocky-Devel.repo
done

${CMD} cp bigtop_hostname0:/root/.ssh/id_rsa.pub bigtop_hostname0.pub

for i in $INSTANCES ; do
	${CMD} cp bigtop_hostname0.pub $i:/root/.ssh/authorized_keys
	${CMD} exec -it $i chown root:root /root/.ssh/authorized_keys
	${CMD} exec -it $i chmod 600 /root/.ssh/authorized_keys
	${CMD} exec -it bigtop_hostname0 ssh -o StrictHostKeyChecking=no $i echo "Connection successful"
done

rm bigtop_hostname0.pub


# setup hostname
rm -f hosts
echo '127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
' > hosts
for i in $INSTANCES ; do
	${CMD} cp getip.sh $i:/root/getip.sh
	IP=$(${CMD} exec -it $i /bin/bash /root/getip.sh | tr -d '\r')
	HOSTNAME=$(${CMD} exec -it $i hostname | tr -d '\r')
	HOSTNAME_SHORT=$(${CMD} exec -it $i hostname -f | tr -d '\r')
	echo "$IP $HOSTNAME_SHORT $HOSTNAME" >> hosts
done

if [ $(basename $PWD) == "scripts" ] ; then
	cat hosts > ../conf/hosts
else
	cat hosts > conf/hosts
fi
rm hosts
