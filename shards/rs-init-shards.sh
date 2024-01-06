#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 <replica-set-name> <shard port number>"
    exit 1
fi

mongosh --port $2 <<EOF
var config = {
    _id: "$1",
    version: 1,
    members: [
        { _id: 1, host: "mongo4:$2" },
        { _id: 2, host: "mongo5:$2" },
    ]
};
rs.initiate(config);
rs.status();
EOF