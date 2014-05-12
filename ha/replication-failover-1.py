#!/usr/bin/env python
 
from pymongo import MongoClient
from pymongo.read_preferences import ReadPreference
from time import sleep
import datetime
 
def log(msg):
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print('%s %s' % (timestamp, msg))
 
log("Connecting to replica set...")
client = MongoClient("localhost:27017", connectTimeoutMS=50)
db = client.test
db.read_preference = ReadPreference.PRIMARY_PREFERRED
 
log("Inserting test doc...")
db.names.insert({ 'a': 1 })
 
while True:
    log('Read: %s' % db.names.find_one())
    sleep(1)
