#!/bin/sh

# Include utilities. Use installed version if available and
# use build version if it isn't.
if [ -e ${prefix}/share/kea/scripts/admin-utils.sh ]; then
    . ${prefix}/share/kea/scripts/admin-utils.sh
else
    . /home/wlodek/dev/kea_110_1/src/bin/admin/admin-utils.sh
fi

VERSION=`mysql_version "$@"`

if [ "$VERSION" != "1.0" ]; then
    printf "This script upgrades 1.0 to 2.0. Reported version is $VERSION. Skipping upgrade.\n"
    exit 0
fi

mysql "$@" <<EOF
ALTER TABLE lease6
    ADD COLUMN hwaddr varbinary(20),
    ADD COLUMN hwtype smallint unsigned,
    ADD COLUMN hwaddr_source int unsigned;

CREATE TABLE lease_hwaddr_source (
    hwaddr_source INT PRIMARY KEY NOT NULL,
    name VARCHAR(40)
) ENGINE = INNODB;

-- See src/lib/dhcp/dhcp/pkt.h for detailed explanation
INSERT INTO lease_hwaddr_source VALUES (1, 'HWADDR_SOURCE_RAW');
INSERT INTO lease_hwaddr_source VALUES (2, 'HWADDR_SOURCE_IPV6_LINK_LOCAL');
INSERT INTO lease_hwaddr_source VALUES (4, 'HWADDR_SOURCE_DUID');
INSERT INTO lease_hwaddr_source VALUES (8, 'HWADDR_SOURCE_CLIENT_ADDR_RELAY_OPTION');
INSERT INTO lease_hwaddr_source VALUES (16, 'HWADDR_SOURCE_REMOTE_ID');
INSERT INTO lease_hwaddr_source VALUES (32, 'HWADDR_SOURCE_SUBSCRIBER_ID');
INSERT INTO lease_hwaddr_source VALUES (64, 'HWADDR_SOURCE_DOCSIS');

UPDATE schema_version SET version='2', minor='0';
EOF

RESULT=$?

exit $?
