#!/usr/bin/env python
 
from pymongo import MongoReplicaSetClient
from pymongo.read_preferences import ReadPreference
from time import sleep
import datetime
import pymongo
import sys
import bson
 
def log(msg):
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print('%s %s' % (timestamp, msg))
 
log("Connecting to replica set...")
client = pymongo.MongoReplicaSetClient('localhost:27017,localhost:27018', replicaset='replset')
# connectTimeoutMS=50)

db = client.testDB
db.read_preference = ReadPreference.PRIMARY_PREFERRED
 
while True:
    for retries in range(1,11):
        try:
            doc = db.testRW.insert({ 'a': 1 })
            log('Inserted doc: %s' % doc)
        except (pymongo.errors.AutoReconnect, bson.errors.InvalidDocument, AssertionError):
            log('Insert failed, retrying #%s' % retries)
            if retries == 10:
                log('Max retries reached, giving up')
                break
            sleep(1)
            continue
        break

    try:
        doc = db.testRW.find().sort([("_id", pymongo.DESCENDING)]).limit(1).next()
        log('Read doc: %s' % doc)
    except pymongo.errors.AutoReconnect:
        log("Can't read")
    sleep(1)
