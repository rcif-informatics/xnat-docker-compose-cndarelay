#!/bin/bash

if [ `docker ps -f name=xnat -q | wc -l` -lt 3 ] ; then
	docker-compose -f /data/docker/xnat-docker-compose-ccfrelay/docker-compose.yml up -d
fi

