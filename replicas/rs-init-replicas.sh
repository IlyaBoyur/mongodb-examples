#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <replica-set-name>"
    exit 1
fi

mongosh <<EOF
var config = {
    "_id": "$1",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "mongo1",
        },
        {
            "_id": 2,
            "host": "mongo2",
        },
        {
            "_id": 3,
            "host": "mongo3",
        }
    ]
};
rs.initiate(config);
rs.status();
EOF
