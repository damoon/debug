#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# https://github.com/nestybox/sysbox/blob/master/sysbox-k8s-manifests/sysbox-install.yaml
# https://github.com/nestybox/sysbox-pkgr/blob/72d84abd652983cf34b4b52f48ba9d027f9a1779/k8s/scripts/sysbox-deploy-k8s.sh

IMAGE="registry.nestybox.com/nestybox/sysbox-deploy-k8s:v0.6.4"

echo "downloading sysbox image"
ctr image ls -q | grep ${IMAGE} 1>/dev/null || ctr image pull ${IMAGE} 1>/dev/null

echo "running sysbox installer"
ctr run \
--privileged \
--rm \
   --mount type=bind,dst=/mnt/host/etc,src=/etc,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/os-release,src=/etc/os-release,options=rbind:rw \
   --mount type=bind,dst=/var/run/dbus,src=/var/run/dbus,options=rbind:rw \
   --mount type=bind,dst=/run/systemd,src=/run/systemd,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/lib/systemd/system,src=/lib/systemd/system,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/etc/systemd/system,src=/etc/systemd/system,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/lib/sysctl.d,src=/lib/sysctl.d,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/usr/bin,src=/usr/bin/,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/usr/local/bin,src=/usr/local/bin/,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/usr/lib/modules-load.d,src=/usr/lib/modules-load.d,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/run,src=/run,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/var/lib,src=/var/lib,options=rbind:rw \
   --mount type=bind,dst=/mnt/host/tmp/ami-scripts,src=/tmp/ami-scripts,options=rbind:rw \
${IMAGE} \
install-sysbox \
bash /mnt/host/tmp/ami-scripts/sysbox-deploy-k8s.sh ce install

#echo "deleting sysbox image"
#ctr images rm ${IMAGE}

# unly flatcar uses these
#   --mount type=bind,dst=/mnt/host/opt/lib/sysctl.d,src=/opt/lib/sysctl.d,options=rbind:rw \
#   --mount type=bind,dst=/mnt/host/opt/bin,src=/opt/bin/,options=rbind:rw \
#   --mount type=bind,dst=/mnt/host/opt/local/bin,src=/opt/local/bin/,options=rbind:rw \
#   --mount type=bind,dst=/mnt/host/opt/lib/modules-load.d,src=/opt/lib/modules-load.d,options=rbind:rw \
