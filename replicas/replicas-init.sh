#!/bin/bash
docker compose -f docker-compose-replicas.yml up -d --remove-orphans
sleep 5
docker compose -f docker-compose-replicas.yml cp rs-init-replicas.sh mongo1:/home/
docker compose -f docker-compose-replicas.yml exec mongo1 bash -c "cd /home && chmod +x rs-init-replicas.sh && ./rs-init-replicas.sh my-replica-set"
