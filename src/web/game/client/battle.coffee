define ['util', 'engine', 'eventemitter', 'pixi'], (Util, engine, EventEmitter) ->
  ###
  # Handles changes to the battle's state
  ###
  class Battle extends EventEmitter
    constructor:(@userId, @model, @socket) ->
      super
      @cardsById = {}
      for card in @model.you.hand
        @cardsById[card._id] = card
      for card in @model.you.field
        @cardsById[card._id] = card
      for opp in @model.opponents
        for card in opp.hand
          @cardsById[card] = card
        for card in opp.field
          @cardsById[card._id] = card
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
        when 'damage'
          card = @getCard(action.target)
          if card?
            card.health -= action.damage
        when 'start-turn'
          @model.activePlayer = action.player
        when 'draw-card'
          if action.card._id?
            @cardsById[action.card._id] = action.card
          @getPlayer(action.player).hand.push action.card
        when 'max-energy'
          @getPlayer(action.player).maxEnergy += action.amount
        when 'energy'
          @getPlayer(action.player).energy += action.amount
        when 'play-card'
          if action.card._id?
            @cardsById[action.card._id] = action.card
          @getPlayer(action.player).field.push action.card
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
    getCard: (id) -> return @cardsById[id]
    getCardsInHand: -> return @model.you.hand
    getCardsOnField: -> return @model.you.field
    getEnemyCardsOnField: ->
      cards = []
      for enemy in @model.opponents
        cards = cards.concat(enemy.field)
      return cards
    getEnergy: -> return @model.you.energy
    getMaxEnergy: -> return @model.you.maxEnergy
    isYourTurn: -> return @model.activePlayer is @userId

    emitEndTurnEvent: -> @socket.emit 'end-turn'
    emitPlayCardEvent: (cardId, target, cb) -> @socket.emit 'play-card', cardId, target, cb
    emitUseCardEvent: (cardId, target, cb) -> @socket.emit 'use-card', cardId, target, cb
