#!/bin/bash

source ./profile.sh

${CMD} cp setup-ambari-repo-script.sh bigtop_hostname0:/root/setup-ambari-repo-script.sh
${CMD} exec -it bigtop_hostname0 /bin/bash /root/setup-ambari-repo-script.sh
