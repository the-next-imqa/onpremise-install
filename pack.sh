#!/usr/bin/env bash

date=$(date '+%Y-%m-%d')

tar -zcvf imqa-packages-$date.tar.gz tar-1.30-9.el8.x86_64.rpm rhel8.x-imqa-packages.tar.xz nvm-packed-12-18.tar.xz install.sh install-nvm.sh configure.sh script pm2