SessionSockets = require 'session.socket.io'
Users          = require '../../lib/models/user'
Errors         = require './errors'
UserManager    = require './usermanager'

exports.init = (server, sessionStore, cookieParser) ->
  io = require('socket.io').listen(server)
  sessionio = new SessionSockets(io, sessionStore, cookieParser)

  # List of connected users and their managers
  userManagers = {}

  sessionio.on 'connection', (err, socket, session) ->
    # Make sure connecting user is logged in
    if err? or not session.user?
      console.log "A user attempted to connect to game server without being logged in"
      socket.disconnect()
      return

    socket.on 'disconnect', ->
      console.log "User #{session.user._id} disconnected from game server"
      if userManagers[session.user._id]
        delete userManagers[session.user._id]

    console.info "User #{session.user._id} connected to game server"

    Users.fromSession session.user, (err, user) ->
      if err?
        console.log "Error getting user: #{session.user}"
        socket.disconnect()
      else
        userManagers[user._id] = new UserManager user, socket
        socket.emit 'connected'


