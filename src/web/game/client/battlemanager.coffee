define ['util', 'engine'], (Util, engine) ->
  class BattleManager
    constructor: (@user, @battle) ->
      @events = {}
      @socket = io.connect()
      @socket.on 'connected', => @onConnected()
      @socket.on 'disconnect', => @onDisconnected()

    onConnected: ->
      console.log "Connected to game server."
      @emit 'connected'

    onDisconnected: ->
      console.log "Disconnected from game server."
      @emit 'disconnected'

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
