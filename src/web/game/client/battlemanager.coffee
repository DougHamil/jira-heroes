define ['util', 'engine', 'client/battle', 'eventemitter'], (Util, engine, Battle, EventEmitter) ->
  POLL_DELAY = 3000 # Poll for battle status every 3 seconds
  class BattleManager extends EventEmitter
    constructor: (@user, @battleId, @cardClasses, @heroClasses) ->
      super
      @battleReady = false
      @socket = io.connect()
      @socket.on 'connected', => @onConnected()
      @socket.on 'disconnect', => @onDisconnected()
      pollStatus = => @pollBattleStatus()
      @pollTimeout = setTimeout(pollStatus, POLL_DELAY)
      @pollBattleStatus()

    pollBattleStatus: ->
      @socket.emit 'battle-status', @battleId, (status) =>
        if not status? and not @battleReady
          @battleReady = true
          @emit 'battle-ready'
          clearTimeout @pollTimeout
        else
          @emit 'battle-status', status
          pollStatus = => @pollBattleStatus()
          @pollTimeout = setTimeout(pollStatus, POLL_DELAY)

    join: ->
      @socket.emit 'join', @battleId, (err, battleModel) =>
        if not err?
          @battle = new Battle(@user._id, battleModel, @socket, @cardClasses, @heroClasses)
          @emit 'joined', @battle
    onConnected: -> @emit 'connected'
    onDisconnected: -> @emit 'disconnected'
    disconnect: -> @socket.disconnect()
    getBattle: -> return @battle
