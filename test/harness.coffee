mongoose = require 'mongoose'
async = require 'async'
Heroes = require '../lib/models/hero'
Cards = require '../lib/models/card'

conn = null
before (done) ->
  conn = mongoose.connect 'mongodb://localhost/jira_heroes_test'
  console.log "Connected to MongoDB"
  async.series [Heroes.load.bind(Heroes), Cards.load.bind(Cards)], (err) ->
    done()

after (done) ->
  conn.connection.db.dropDatabase()
  mongoose.disconnect()
  console.log "Dropped test database and closed MongoDB connection"
  done()
