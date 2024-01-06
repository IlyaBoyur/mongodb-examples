#!/bin/bash
docker compose -f docker-compose-shards.yml up -d --remove-orphans
sleep 4
# Initialize configuration server
# (default --configsvr port is 27019)
docker compose -f docker-compose-shards.yml exec -it mongoconfig mongosh --port 27019 --eval "rs.initiate({
    _id: "shard-config-set",
    configsvr: true,
    members: [{_id: 0, host: "mongoconfig:27019"}]
})"
# Initialize shard servers
# (default --configsvr port is 27018)
docker compose -f docker-compose-shards.yml cp rs-init-shards.sh mongo4:/home/
docker compose -f docker-compose-shards.yml exec mongo4 bash -c "cd /home && chmod +x rs-init-shards.sh && ./rs-init-shards.sh shard-set 27018"
