CONFIG = require './config'
async = require 'async'
Server = require './server'
mongoose       = require 'mongoose'
UserController = require '../lib/controllers/user'
DeckController = require '../lib/controllers/deck'
CardController = require '../lib/controllers/card'
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
Decks = require '../lib/models/deck'
Cards = require '../lib/models/card'
Heroes = require '../lib/models/hero'

mongoose.connect("mongodb://#{options.databaseServer}:#{options.databasePort}/#{options.database}")
db = mongoose.connection
db.on('error', console.error.bind(console, 'connection error:'))
db.once 'open', ->
  async.series [Cards.load.bind(Cards), Heroes.load.bind(Heroes)], (err) ->
    UserController(server.app, Users)
    DeckController(server.app, Users)
    CardController(server.app, Users)
    ViewsController(server.app)
    server.app.listen(3001)
    #gameServer.init server.app.listen(3001), server.sessionStore, server.cookieParser
    console.log 'Listening on port 3001'
