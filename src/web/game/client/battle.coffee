define ['util', 'engine', 'eventemitter', 'pixi'], (Util, engine, EventEmitter) ->
  ###
  # Handles changes to the battle's state
  ###
  class Battle extends EventEmitter
    constructor:(@userId, @model, @socket) ->
      super
      @socket.on 'player-connected', (userId) => @onPlayerConnected(userId)
      @socket.on 'player-disconnected', (userId) => @onPlayerDisconnected(userId)
      @socket.on 'player-ready', (userId) => @onPlayerReadied(userId)
      @socket.on 'your-turn', (actions) => @processAndEmit('your-turn', actions)
      @socket.on 'opponent-turn', (actions) => @processAndEmit('opponent-turn', actions)
      @socket.on 'phase', (oldPhase, newPhase) => @onPhaseChanged(oldPhase, newPhase)

    processAndEmit: (event, actions) ->
      for action in actions
        @process(action)
      @emit event, actions

    process: (action) ->
      console.log action
      switch action.type
        when 'start-turn'
          @model.activePlayer = action.player
        when 'draw-card'
          console.log action
          @getPlayer(action.player).hand.push action.card
        when 'max-energy'
          @getPlayer(action.player).maxEnergy += action.amount
        when 'energy'
          @getPlayer(action.player).energy += action.amount

    onPhaseChanged:(oldPhase, newPhase) ->
      @model.state.phase = newPhase
      @emit 'phase', oldPhase, newPhase

    onPlayerReadied: (userId) ->
      @model.readiedPlayers.push userId
      @emit 'player-readied', userId

    onPlayerConnected: (userId) ->
      @model.connectedPlayers.push userId
      @emit 'player-connected', userId

    onPlayerDisconnected: (userId) ->
      @model.connectedPlayers = @model.connectedPlayers.filter (p) -> p isnt userId
      @emit 'player-disconnected', userId

    getPlayer: (id) ->
      if id is @userId
        return @model.you
      else
        for user in @model.opponents
          if user.userId is id
            return user
        return null

    getConnectedPlayers: -> return @model.connectedPlayers
    getPhase: -> return @model.state.phase
    isReadied: -> return @userId in @model.readiedPlayers
    getCardsInHand: -> return @model.you.hand
    getCardsOnField: -> return @model.you.field
    getEnergy: -> return @model.you.energy
    getMaxEnergy: -> return @model.you.maxEnergy

    emitReadyEvent: (cb) -> @socket.emit 'ready', cb
    emitPlayCardEvent: (cardId, target, cb) -> @socket.emit 'play-card', cardId, target, cb
