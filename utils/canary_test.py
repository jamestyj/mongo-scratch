#!/usr/bin/env python

import pymongo
import sys

try:
  db = pymongo.MongoClient("localhost:27017", connectTimeoutMS=5000, socketTimeoutMS=5000).admin
  print db.command("connPoolStats")
except pymongo.errors.ConnectionFailure as e: 
  print e
  sys.exit(1)
