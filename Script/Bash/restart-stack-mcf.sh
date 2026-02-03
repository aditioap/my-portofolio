#!/bin/bash

# Check Service Fincore
service=`docker stack ls |grep "FIN-MAF" |awk '{print $2}'`

# Change to the directory containing the docker-compose.yml file
function changedir {

  cd /data/source/mcf

}

# Restart the stack's services
function execute {

  docker stack deploy -c docker-compose-mcf.yml --with-registry-auth FIN-MCF

}


if [ "${service}" != "10" ]; then

        changedir && execute
else
        exit 1
fi



docker service ls |grep "FIN-MCF" |awk '{print $4}'
docker service ls |grep "FIN-MCF" |awk '{print $4}' |sed 's/\///g' |sed 's/.$//'

docker service ls |grep "FIN-MCF" |awk '{print $4}' |sed 's/\///g' |sed 's/.$//' |grep "0" |wc -l


