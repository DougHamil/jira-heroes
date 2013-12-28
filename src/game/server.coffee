UserController = require '../controllers/user'
ModelHelper    = require '../models/helper'
UserModel      = require '../models/user'
User           = require './user'
SessionSockets = require 'session.socket.io'
Errors         = require './errors'
ConnectionManager = require './connectionmanager'
BattleManager = require './battlemanager'

exports.init = (server, sessionStore, cookieParser) ->
  io = require('socket.io').listen(server)
  sessionio = new SessionSockets(io, sessionStore, cookieParser)
  #
  # List of active connections
  connectionsByUserId = {}

  sessionio.on 'connection', (err, socket, session) ->
    # Make sure connecting user is logged in
    if err? or not UserController.loggedIn(session)
      console.log "A user attempted to connect to game server without being logged in"
      socket.disconnect()
      return

    socket.on 'disconnect', ->
      console.log "User #{session.user._id} disconnected from game server"

    console.info "User #{session.user._id} connected to game server"
    # Pull the user from the database, the session's user object to deep-populate it
    UserModel.findOne {_id:session.user._id}, (err, userModel) ->
      if err?
        console.log "Unable to find logged-in user"
        socket.disconnect()
        return
      user = new User(userModel)
      connectionsByUserId[user.id] = new ConnectionManager battleManager, socket, user
      socket.emit 'connected'


