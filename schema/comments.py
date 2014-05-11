#!/usr/bin/env python

# Sample program that implements comments with paging.
# For details, see:
#
#   http://docs.mongodb.org/ecosystem/use-cases/storing-comments/
#
# Schema:
#
# (1) 'discussions' collection: {
#   _id     : <ID>,
#   comments: <NUMBER_OF_COMMENTS>
# }
#
# (2) 'comments' collection: {
#   _id     : { discussion_id: <DISCUSSION_ID>, page: <PAGE> },
#   comments: [
#     { author: <AUTHOR>,
#       text  : <TEXT>,
#       ts    : <TIME_STAMP> },
#     ...
#   ]
# }

from bson     import objectid
from datetime import datetime
from pymongo  import MongoClient

PAGE_SIZE =  3

db = MongoClient().sample_schema

def drop_collections():
	db.discussions.drop()
	db.comments.drop()

def get_discussion_id():
	# Get discussion_id. This is usually taken from the application context but in this
	# example we will just use the first one, creating one if necessary.
	if db.discussions.count() == 0:
		discussion_id = db.discussions.insert({ 'count': -1 })
	else:
		discussion_id = db.discussions.find_one()['_id']
	return discussion_id

def insert_comment(comment):
	# Atomically increment the comments counter for the specific discussion
	count = db.discussions.find_and_modify(
		{ '_id': comment['discussion_id'] },
		{ '$inc': { 'count': 1 }},
		new = True)['count']

	# Calculate the page number
	page = count / PAGE_SIZE
	print "page = %d / %d = %d" % (count, PAGE_SIZE, page)

	# Upsert the comment to the corresponding document
	db.comments.update(
		{ '_id': { 'discussion_id': comment['discussion_id'], 'page': page } },
		{ '$push': {
		    'comments': {
		      'author': comment['author'],
		      'text'  : comment['text'],
		      'ts'    : datetime.now()
		    }
		  }
		},
		upsert = True)

# drop_collections()
insert_comment({
	'discussion_id': get_discussion_id(),
	'author': 'James Tan',
	'text': 'This is my comment...'
})
