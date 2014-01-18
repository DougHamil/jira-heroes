define ['util', 'engine', 'eventemitter', 'pixi'], (Util, engine, EventEmitter) ->
  ###
  # Handles changes to the battle's state
  ###
  class Battle extends EventEmitter
    constructor:(@userId, @model, @socket) ->
      super
      @socket.on 'player-connected', (userId) => @onPlayerConnected(userId)
      @socket.on 'player-disconnected', (userId) => @onPlayerDisconnected(userId)
      @socket.on 'your-turn', (actions) => @processAndEmit('your-turn', actions)
      @socket.on 'opponent-turn', (actions) => @processAndEmit('opponent-turn', actions)
      @socket.on 'phase', (oldPhase, newPhase) => @onPhaseChanged(oldPhase, newPhase)
      @socket.on 'action', (actions) => @processAndEmit 'action', actions

    processAndEmit: (event, actions) ->
      for action in actions
        @process(action)
      @emit event, actions

    process: (action) ->
      switch action.type
        when 'start-turn'
          @model.activePlayer = action.player
        when 'draw-card'
          @getPlayer(action.player).hand.push action.card
        when 'max-energy'
          @getPlayer(action.player).maxEnergy += action.amount
        when 'energy'
          @getPlayer(action.player).energy += action.amount
      console.log action
      @emit 'action-'+action.type, action

    onPhaseChanged:(oldPhase, newPhase) ->
      @model.state.phase = newPhase
      @emit 'phase', oldPhase, newPhase

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
    getCardsInHand: -> return @model.you.hand
    getCardsOnField: -> return @model.you.field
    getEnergy: -> return @model.you.energy
    getMaxEnergy: -> return @model.you.maxEnergy
    isYourTurn: -> return @model.activePlayer is @userId

    emitEndTurnEvent: -> @socket.emit 'end-turn'
    emitPlayCardEvent: (cardId, target, cb) -> @socket.emit 'play-card', cardId, target, cb
