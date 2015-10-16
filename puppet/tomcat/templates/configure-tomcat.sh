#!/bin/bash
sleep 20

/home/$id/scripts/run-cli-script <%= tomcat_dir %>/conf/scripts/configure-tomcat.cli <%= tomcat_dir %>

rc=$?
if [[ $rc == 0 ]]; then
    touch <%= tomcat_dir %>/props/libs/tomcat.configured
fi
exit $rc