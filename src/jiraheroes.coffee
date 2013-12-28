CONFIG = require './config'
Server = require './server'
mongoose       = require 'mongoose'
UserController = require '../lib/controllers/user'
ViewsController = require '../lib/controllers/views'
#GameServer = require './game/server'

options = CONFIG
options.databaseServer = options.databaseServer || 'localhost'
options.databasePort = options.databasePort || 27017
options.database = options.database || 'jira-heroes'
options.sessionSecret = options.sessionSecret || 'JIRA_HEROES_SECRET'
options.users = UserController

server = Server(options)

jira = require('../lib/jira/api')(options)
Users = require('../lib/models/user')(jira)

mongoose.connect("mongodb://#{options.databaseServer}:#{options.databasePort}/#{options.database}")
db = mongoose.connection
db.on('error', console.error.bind(console, 'connection error:'))
db.once 'open', ->
  UserController(server.app, Users)
  ViewsController(server.app)
  #gameServer.init server.app.listen(3001), server.sessionStore, server.cookieParser
  console.log 'Listening on port 3001'
