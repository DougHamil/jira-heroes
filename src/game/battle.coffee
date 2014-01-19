Errors = require './errors'
DrawCardAction = require './actions/drawcard'
StartTurnAction = require './actions/startturn'
ActionProcessor = require './actionprocessor'
CardCache = require '../../lib/models/cardcache'
PlayerHandler = require './playerhandler'
CardHandler = require './cardhandler'
Actions = require './actions'
Events = require './events'

CARDS_DRAWN_PER_TURN = 1 # Number of cards to draw each turn
INITIAL_CARD_COUNT = 3 # Second turn player gets 3 cards to start
ENERGY_INCREASE_PER_TURN = 1

class Battle
  constructor: (@model) ->
    @players = {}
    @sockets = {}
    @field = {}
    @cards = {}
    @abilities = []
    for player in @model.players
      cardsById = {}
      @players[player.userId] = new PlayerHandler(@, player)
      for card in player.deck.cards
        cardsById[card._id] = card
        @cards[card._id] = new CardHandler(@, @players[player.userId], card)
      player.cards = cardsById
      @registerPlayer(player.userId, @players[player.userId])

    # Start the battle if it's still in initial phase
    if @model.state.phase is 'initial'
      @startGame()

  registerPlayer: (userId, handler) ->
    handler.on Events.PLAY_CARD, @onPlayCard(userId)               # Deploy card from hand to field
    handler.on Events.END_TURN, @onEndTurn(userId)                 # Turn over
    handler.on Events.USE_CARD, @onUseCard(userId)                 # Player used a card, targeting something

  ###
  # EVENTS
  ###
  # Called when a user disconnects from this battle
  onDisconnect: (user) ->
    @players[user._id.toString()].disconnect()
    delete @sockets[user._id]
    @emitAll 'player-disconnected', user._id

  # Called when a user connects to this battle
  onConnect: (user, socket) ->
    @players[user._id.toString()].connect socket
    @sockets[user._id] = socket
    @emitAllBut user._id.toString(), 'player-connected', user._id

  # Called when a player used a card, targeting another card
  onUseCard: (userId) ->
    (card, target, actions) =>
      @emitAllButActive 'opponent-'+Events.USE_CARD, userId, card, target._id
      @emitActionsAll 'action', actions

  # Called when the player has played a card
  onPlayCard: (userId) ->
    (card, actions) =>
      @emitAllButActive 'opponent-'+Events.PLAY_CARD, userId, card
      @emitActionsAll 'action', actions

  # Called when the player has completed his turn
  onEndTurn: (userId) ->
    (actions) =>
      @emitAllButActive 'opponent-'+Events.END_TURN, userId
      @emitActionsAll 'action', actions
      @nextTurn()

  # Registers an ability as active and the ability will be passed all events
  registerAbility: (ability) ->
    @abilities.push ability

  # Removes an ability from registry, this de-activates the ability.
  unregisterAbility: (ability) ->
    @abilities.splice(@abilities.indexOf(ability), 1)

  processActions: (actions) ->
    return ActionProcessor.process(@, actions, @abilities)

  emitActive: (action, data...) ->
    @emit @model.state.activePlayer, action, data...

  emitActionsActive: (event, actions) ->
    @emit @model.state.activePlayer, event, @sanitizePayloads(@model.state.activePlayer, actions)

  emit: (userId, action, data...) ->
    if @sockets[userId]?
      @sockets[userId].emit action, data...

  emitActionsAllButActive: (event, actions) ->
    @emitActionsAllBut @model.state.activePlayer, event, actions

  emitAllButActive: (action, data...) ->
    @emitAllBut @model.state.activePlayer, action, data...

  emitActionsAllBut: (ignore, event, actions) ->
    for userId, socket of @sockets
      if ignore isnt userId
        socket.emit event, @sanitizePayloads(userId, actions)

  emitAllBut: (ignore, action, data...) ->
    for userId, socket of @sockets
      if ignore isnt userId
        socket.emit action, data...

  emitActionsAll: (event, actions) ->
    for userId, socket of @sockets
      socket.emit event, @sanitizePayloads(userId, actions)

  emitAll: (action, data...) ->
    for userId, socket of @sockets
      socket.emit action, data...

  startGame: ->
    @model.state.phase = 'game'
    @assignNextActivePlayer()
    initActions = []
    for i in [0..INITIAL_CARD_COUNT]
      initActions.push new DrawCardAction(@getActivePlayer())
    for p in @getNonActivePlayers()
      for i in [0..(INITIAL_CARD_COUNT-1)]
        initActions.push new DrawCardAction(@getPlayer(p))
    @nextTurn(initActions)

  nextTurn: (initActions)->
    # Pick the next player and set to active
    if not initAction?
      @assignNextActivePlayer()
    actions = initActions || []
    actions.push new StartTurnAction(@getActivePlayer())
    payloads = @processActions(actions)
    @emitActionsActive 'your-turn', payloads
    @emitActionsAllButActive 'opponent-turn', payloads

  sanitizePayloads: (userId, payloads) ->
    out = []
    for payload in payloads
      if payload.player? and payload.player isnt userId and payload.sanitized?
        out.push payload.sanitized
      else
        out.push payload
    return out

  assignNextActivePlayer: ->
    if @model.state.activePlayer?
      @model.state.activePlayer = @getNextPlayer(@model.state.activePlayer).userId
    else
      @model.state.activePlayer = @getRandomPlayer().userId

  getNextPlayer: (userId)->
    idx = @model.users.indexOf(userId)
    if idx is @model.players.length - 1
      idx = 0
    else
      idx++
    return @players[@model.users[idx]]

  getRandomPlayer: ->
    return @model.players[Math.floor(Math.random() * @model.players.length)]

  getActivePlayer: ->
    return @getPlayer(@model.state.activePlayer)

  getNonActivePlayers: ->
    return @model.users.filter (u) => u isnt @model.state.activePlayer

  getPlayer: (playerId) ->
    if typeof playerId is 'object'
      playerId = playerId.userId
    return @getPlayerHandler(playerId).player

  getPlayerHandler: (playerId) ->
    if typeof playerId is 'object'
      if playerId.userId?
        playerId = playerId.userId
      else
        playerId = ''
    return @players[playerId]

  getOtherPlayers: (playerId) ->
    if typeof playerId isnt 'string'
      playerId = playerId._id
    return (p for id, p of @players when id isnt playerId)

  # Get the hero for the player ID
  getHero: (userId) ->
    if typeof userId is 'object' and userId.userId?
      return @getPlayerHandler(userId.userId).getHero()
    player = @getPlayerHandler(userId)
    if player?
      return player.getHero()
    else
      return null

  getCardHandler: (cardId) ->
    return @cards[cardId]

  getCard: (cardId) ->
    for _, p of @players
      card = p.getCard(cardId)
      if card?
        return card
    return null

  getFieldCards: (player) ->
    if player?
      if typeof player is 'object'
        if player instanceof PlayerHandler
          return player.getFieldCards()
        else if player.userId?
          return @getPlayerHandler(player.userId).getFieldCards()
      else
        return @getPlayerHandler(player).getFieldCards()
    else
      fieldCards = []
      for _, p of @players
        fieldCards = fieldCards.concat p.getFieldCards()
      return fieldCards
    return null

  sanitizeOpponentData: (player) ->
    out =
      userId: player.getUserId()
      energy: player.getEnergy()
      maxEnergy: player.getMaxEnergy()
      hero: player.getHero() #TODO: Make sure that all hero data is fine for the player to see (secrets and such should be stripped)
      field: player.getFieldCards()
      hand: player.getHandCards().map( (c) -> c._id) # Player does not get to see opponent's cards
      deckSize: player.getDeckCards().length

  getOpponentsData: (user) ->
    others = @model.players.filter (p) -> p.userId isnt user._id.toString()
    return others.map((o) => @sanitizeOpponentData(@players[o.userId]))

  getData: (user) ->
    player = @players[user._id]
    out =
      connectedPlayers: (playerId for playerId, socket of @sockets)
      activePlayer: @model.state.activePlayer
      state:
        phase:@model.state.phase
      you:
        maxEnergy: player.getMaxEnergy()
        energy: player.getEnergy()
        hero: player.getHero()
        field: player.getFieldCards()
        hand: player.getHandCards()
        deckSize: player.getDeckCards().length # Player doesn't get to know what card is in deck
      opponents: @getOpponentsData(user)

module.exports = Battle
