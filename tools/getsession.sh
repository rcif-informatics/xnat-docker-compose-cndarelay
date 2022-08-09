#!/bin/bash
if [ $# -eq 0 ]; then
    echo "ERROR:  A host must be specified."
else
    DB_HOST=$1
    if ! [[ $1 =~ ^.*[.].*$ ]] ; then
        DB_HOST="${DB_HOST}.nrg.wustl.edu"
    fi
    export DB_HOST
    echo "DB_HOST=$DB_HOST"
    read -p "ENTER USERNAME: " USR
    read -s -p "ENTER PASSWORD: " PW;
    JSESSIONID=`curl -s -k -v -u $USR:$PW https://$DB_HOST/data/JSESSIONID`;export JSESSIONID;echo "$JSESSIONID"
fi
