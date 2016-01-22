#!/bin/sh

chown -R nginx:nogroup ${WWW_DIR}
chown -R mysql:mysql ${MYSQL_DIR}

sh -c "$@"