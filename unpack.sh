#!/bin/bash
# Purpose: Unpack RPM archives (author: @unSpawn)
# Args: /path/to/archive
# Deps: Bash, GNU utils, RPM
rpmDetails() { for Q in changelog provides requires scripts triggers triggerscripts; do
  rpm -q -p --${Q} "${f}" 2>&1 | grep -v NOKEY >"${Q}.log"
done; }
rpmUnpack() {
  f=$(readlink -f "${f}")
  file "${f}" | grep -q "RPM.v" &&
    {
      d=$(basename "${f}" .rpm)
      d="./${d:=ERROR_$$}"
      mkdir -p "${d}" &&
        { cd "${d}" && rpm2cpio "${f}" | cpio -idmv && rpmDetails "${f}"; }
    }
}
for f in $@; do rpmUnpack "${f}"; done
exit 0
