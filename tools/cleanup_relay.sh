#!/bin/bash

HOST=`hostname --fqdn` 

JSESSIONID=`curl -s -k -n https://$HOST/data/projects`

curl -s -k --cookie JSESSIONID=$JSESSIONID https://$HOST/data/projects

