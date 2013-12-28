define ['util', 'engine'], (Util, engine) ->
  class GameManager
    constructor: (@hero, @campaign) ->
      @events = {}
      @unhandledEvents = {}
      @socket = io.connect()
      @socket.on 'connected', => @onConnected()
      @socket.on 'disconnect', => @onDisconnected()

    # Attempt to move the hero to the node
    moveTo: (node, cb) ->
      @socket.emit 'move', node, cb

    # Called when the server has closed the socket connection (or connection time-out)
    onDisconnected: ->
      console.log 'Disconnected from game server.'
      @emit 'disconnect'

    # Called when the server is ready to handle socket messages
    onConnected: ->
      console.log "Joining campaign..."
      # Connect to the campaign
      @socket.emit 'join', @hero._id, @campaign._id, (err, data) =>
        if err?
          @socket.disconnect()
        else
          console.log "Emitting event"
          @emit 'joined', data

    # Disconnect from server
    disconnect: ->
      @socket.disconnect()

    #---------------
    # Event Handling
    #---------------
    on: (event, cb) ->
      if not @events[event]?
        @events[event] = []
      @events[event].push cb

    emit: (event, args...) ->
      if @events[event]?
        for cb in @events[event]
          cb args...
