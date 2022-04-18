#!/bin/bash

if [ ${YUM_PACKAGES:+x} ]; then
    echo "-- INSTALLING YUM PACKAGES $YUM_PACKAGES --"
    yum install -y $YUM_PACKAGES
fi

#update any certs we have mounted to: /usr/share/pki/ca-trust-source/anchors/
update-ca-trust

exec "$@"
