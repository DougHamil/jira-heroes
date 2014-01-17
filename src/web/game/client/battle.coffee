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
      @socket.on 'your-turn', (energy) => @onYourTurn(energy)
      @socket.on 'phase', (oldPhase, newPhase) => @onPhaseChanged(oldPhase, newPhase)

    onYourTurn: (energyIncrease) ->
      @model.you.energy += energyIncrease
      @emit 'your-turn', energyIncrease

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

    getConnectedPlayers: -> return @model.connectedPlayers
    getPhase: -> return @model.state.phase
    isReadied: -> return @userId in @model.readiedPlayers
    getCardsInHand: -> return @model.you.hand
    getCardsOnField: -> return @model.you.field
    getEnergy: -> return @model.you.energy

    emitReadyEvent: (cb) -> @socket.emit 'ready', cb
    emitPlayCardEvent: (cardId, target, cb) -> @socket.emit 'play-card', cardId, target, cb
