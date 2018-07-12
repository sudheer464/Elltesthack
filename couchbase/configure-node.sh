#!/bin/bash

set -x
set -m

/entrypoint.sh couchbase-server &

sleep 15

# Setup index and memory quota
curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=2784 -d index                                                                             MemoryQuota=512

# Setup services
curl -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1q                                                                             l%2Cindex

# Setup credentials
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrato                                                                             r -d password=password

# Setup Memory Optimized Indexes
curl -i -u Administrator:password -X POST http://127.0.0.1:8091/settings/indexes                                                                              -d 'storageMode=memory_optimized'


# Set up new buckets


curl -s -XPOST -u Administrator:password -d name=default -d authType=none -d ram                                                                             QuotaMB=928  -d flushEnabled=1 -d proxyPort=11218  "http://127.0.0.1:8091/pools/                                                                             default/buckets"

curl -s -XPOST -u Administrator:password -d name=entities -d authType=none -d ra                                                                             mQuotaMB=928 -d flushEnabled=1 -d proxyPort=11216  "http://127.0.0.1:8091/pools/                                                                             default/buckets"

curl -s -XPOST -u Administrator:password -d name=sessionextensions -d authType=n                                                                             one -d ramQuotaMB=928 -d flushEnabled=1  -d proxyPort=11217  "http://127.0.0.1:8                                                                             091/pools/default/buckets"



echo "Type: $TYPE"

if [ "$TYPE" = "WORKER" ]; then
  echo "Sleeping ..."
  sleep 15

  #IP=`hostname -s`
  IP=`hostname -I | cut -d ' ' -f1`
  echo "IP: " $IP

  echo "Auto Rebalance: $AUTO_REBALANCE"
  if [ "$AUTO_REBALANCE" = "true" ]; then
    couchbase-cli rebalance --cluster=$COUCHBASE_MASTER:8091 --user=Administrato                                                                             r --password=password --server-add=$IP --server-add-username=Administrator --ser                                                                             ver-add-password=password
  else
    couchbase-cli server-add --cluster=$COUCHBASE_MASTER:8091 --user=Administrat                                                                             or --password=password --server-add=$IP --server-add-username=Administrator --se                                                                             rver-add-password=password
  fi;
fi;

fg 1
