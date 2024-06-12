#!/bin/bash
 
if [[ "$*" =~ ^.*\-\-rebuild ]] ; then
        docker-compose -f /data/docker/xnat-docker-compose-cndarelay/docker-compose.yml build
elif [[ "$*" =~ ^.*\-\-restart ]] ; then
        docker-compose -f /data/docker/xnat-docker-compose-cndarelay/docker-compose.yml down
fi

if [ `docker ps -f name=xnat -q | wc -l` -lt 3 ] ; then
	docker-compose -f /data/docker/xnat-docker-compose-cndarelay/docker-compose.yml up -d
fi

