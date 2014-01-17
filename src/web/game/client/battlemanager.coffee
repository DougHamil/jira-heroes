define ['util', 'engine'], (Util, engine) ->
  POLL_DELAY = 3000 # Poll for battle status every 3 seconds
  class BattleManager
    constructor: (@user, @battle) ->
      @battleReady = false
      @events = {}
      @socket = io.connect()
      @socket.on 'connected', => @onConnected()
      @socket.on 'disconnect', => @onDisconnected()
      @socket.on 'player-connected', (userId) => @onPlayerConnected(userId)
      @socket.on 'player-disconnected', (userId) => @onPlayerDisconnected(userId)
      pollStatus = => @pollBattleStatus()
      @pollTimeout = setTimeout(pollStatus, POLL_DELAY)
      @pollBattleStatus()

    pollBattleStatus: ->
      @socket.emit 'battle-status', @battle._id, (status) =>
        if not status? and not @battleReady
          @battleReady = true
          @emit 'battle-ready'
          clearTimeout @pollTimeout
        else
          @emit 'battle-status', status
          pollStatus = => @pollBattleStatus()
          @pollTimeout = setTimeout(pollStatus, POLL_DELAY)

    join: ->
      @socket.emit 'join', @battle._id, (err, battle) =>
        if not err?
          console.log battle
          @model = battle
          @emit 'joined', battle
    onConnected: -> @emit 'connected'
    onDisconnected: -> @emit 'disconnected'
    onPlayerConnected: (userId) ->
      @model.battle.connectedPlayers.push userId
      @emit 'player-connected', userId
    onPlayerDisconnected: (userId) ->
      @model.battle.connectedPlayers = @model.battle.connectedPlayers.filter (u) -> u isnt userId
      @emit 'player-disconnected', userId
    disconnect: -> @socket.disconnect()

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
