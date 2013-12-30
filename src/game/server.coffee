SessionSockets = require 'session.socket.io'
Errors         = require './errors'
UserManager    = require './usermanager'

module.exports = (expressServer, sessionStore, cookieParser, Users) ->
  io = require('socket.io').listen(expressServer, {log:false})
  sessionio = new SessionSockets(io, sessionStore, cookieParser)

  # List of connected users and their managers
  userManagers = {}

  sessionio.on 'connection', (err, socket, session) ->
    # Make sure connecting user is logged in
    if err? or not session.user?
      if err?
        console.log 'Socket.IO Error: '+err
      socket.disconnect()
      return

    socket.on 'disconnect', ->
      if userManagers[session.user._id]
        delete userManagers[session.user._id]

    Users.fromSession session.user, (err, user) ->
      if err?
        console.log "Error getting user: #{session.user}"
        socket.disconnect()
      else
        userManagers[user._id] = new UserManager user, socket
        socket.emit 'connected'


