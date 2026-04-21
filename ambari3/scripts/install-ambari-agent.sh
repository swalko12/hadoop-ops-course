#!/bin/bash

set -ex

source ./profile.sh

INSTANCES="bigtop_hostname0 bigtop_hostname1 bigtop_hostname2 bigtop_hostname3"

for i in $INSTANCES ; do
	HOSTNAME=$(echo $i |sed s/_/-/g)".${DOMAIN}"
	${CMD} cp install-ambari-agent-script.sh $i:/root/install-ambari-agent-script.sh
	${CMD} exec -it $i /bin/bash /root/install-ambari-agent-script.sh $HOSTNAME
done

