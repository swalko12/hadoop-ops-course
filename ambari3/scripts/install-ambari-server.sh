#!/bin/bash

set -ex

source ./profile.sh

${CMD} cp install-ambari-server-script.sh bigtop_hostname0:/root/install-ambari-server-script.sh
${CMD} exec -it bigtop_hostname0 /bin/bash /root/install-ambari-server-script.sh

