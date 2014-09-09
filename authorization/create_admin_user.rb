#!/usr/bin/env ruby

# Demo Ruby script that creates an admin MongoDB user. Supports and tested on
# MongoDB 2.4 and 2.6.
#
# To create users in the new authorization format, MongoDB Ruby driver >1.10.0
# is required. For details, see:
# - https://github.com/mongodb/mongo-ruby-driver/releases
# - http://docs.mongodb.org/manual/release-notes/2.6-upgrade-authorization/

require 'slop'
require 'mongo'

opts = Slop.parse(ARGV, help: true) do
  banner 'Usage: create_user.rb [options]'
  on       'hostname=', "MongoDB hostname",    default: 'localhost'
  on 'p=', 'port=',     "MongoDB port number", default: 27017
end

client = Mongo::MongoClient.new(opts[:hostname], opts[:port])
db = client['admin']

SERVER_VERSION = db.command({ buildinfo: 1 })['version']
puts "MongoDB server version: #{SERVER_VERSION}"

ADMIN_ROLES = if SERVER_VERSION > "2.6"
  # For details, see http://docs.mongodb.org/v2.6/reference/built-in-roles/.
  %w[ root ]
else
  # For details, see http://docs.mongodb.org/v2.4/reference/user-privileges/.
  %w[ readWriteAnyDatabase dbAdminAnyDatabase userAdminAnyDatabase clusterAdmin ]
end

begin
  # Remove existing user first (if exists) to ensure proper updating of roles
  db.remove_user('admin')
  puts "Updating 'admin' user"
rescue Mongo::OperationFailure
  # 'admin' user does not exist
  puts "Adding 'admin' user"
end

# https://github.com/mongodb/mongo-ruby-driver/wiki/Authentication-Examples#mongodb-cr
# http://api.mongodb.org/ruby/current/Mongo/DB.html#add_user-instance_method
db.add_user('admin', 'password', read_only=false, roles: ADMIN_ROLES)
