Errors = require './errors'
CardCache = require '../../lib/models/cardcache'
PlayerHandler = require './playerhandler'
CardHandler = require './cardhandler'
Actions = require './actions'
Events = require './events'

CARDS_DRAWN_PER_TURN = 1 # Number of cards to draw each turn
INITIAL_CARD_COUNT = 3 # Second turn player gets 3 cards to start

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

  registerPlayer: (userId, handler) ->
    handler.on Events.READY, @onReady(userId)                      # Player is in battle and wishes to start
    handler.on Events.PLAY_CARD, @onPlayCard(userId)               # Deploy card from hand to field
    handler.on Events.END_TURN, @onEndTurn(userId)                 # Turn over
    handler.on Events.USE_CARD, @onUseCard(userId)                 # Player used a card, targeting something

  ###
  # EVENTS
  ###
  # Called when a user connects to this battle
  onConnect: (user, socket) ->
    @players[user._id.toString()].connect socket
    @sockets[user._id] = socket

  # Called when the player is ready to start the battle
  onReady: (userId) ->
    =>
      if @model.state.playersReady.length is @model.players.length
        @startGame()

  # Called when a player used a card, targeting another card
  onUseCard: (userId) ->
    (card, target, actions) ->
      @emitAllButActive 'opponent-'+Events.USE_CARD, userId, card, target._id, actions

  # Called when the player has played a card
  onPlayCard: (userId) ->
    (card, actions) =>
      @emitAllButActive 'opponent-'+Events.PLAY_CARD, userId, card, actions

  # Called when the player has completed his turn
  onEndTurn: (userId) ->
    (actions) =>
      @emitAllButActive 'opponent-'+Events.END_TURN, userId, actions
      @nextTurn()

  # Registers an ability as active and the ability will be passed all events
  registerAbility: (ability) ->
    @abilities.push ability

  # Removes an ability from registry, this de-activates the ability.
  unregisterAbility: (ability) ->
    @abilities.splice(@abilities.indexOf(ability), 1)

  _processActions: (count, payloads, actions) ->
    if actions.length <= 0
      return payloads
    else
      # Enact all of the actions
      spawnedActions = []
      for action in actions
        [payload, generatedActions] = action.enact(@)
        if payload?
          if payload instanceof Array
            payloads = payloads.concat(payload)
          else
            payloads.push payload
        if generatedActions?
          spawnedActions = spawnedActions.concat generatedActions
      # Filter new actions through passive abilities
      spawnedActions = @filterActions(spawnedActions)
      # Recursively call until spawned actions are empty
      return @_processActions count++, payloads, spawnedActions

  processActions: (actions) ->
    payloads = []
    count = 0
    return @_processActions(count, payloads, actions)

  # Run a list of actions through all of the registered abilities.
  # Each ability will filter the action list based on their behavior
  filterActions: (actions) ->
    for ability in @abilities
      ability.handle @, actions
    return actions

  emitActive: (action, data...) ->
    @emit @model.state.activePlayer, action, data...

  emit: (userId, action, data...) ->
    @sockets[userId].emit action, data...

  emitAllButActive: (action, data...) ->
    @emitAllBut @model.state.activePlayer, action, data...

  emitAllBut: (ignore, action, data...) ->
    for userId, socket of @sockets
      if ignore isnt userId
        socket.emit action, data...

  emitAll: (action, data...) ->
    for userId, socket of @sockets
      socket.emit action, data...

  startGame: ->
    oldPhase = @model.state.phase
    @model.state.phase = 'game'
    @emitAll 'phase', oldPhase, @model.state.phase
    @assignNextActivePlayer()
    @drawCards(@model.state.activePlayer, INITIAL_CARD_COUNT)
    for p in @getNonActivePlayers()
      @drawCards(p, INITIAL_CARD_COUNT - 1)
    @nextTurn(true)

  nextTurn: (firstTurn)->
    # Pick the next player and set to active
    if not firstTurn? or not firstTurn
      @assignNextActivePlayer()
    @emitActive 'your-turn'
    @emitAllButActive 'opponent-turn', @model.state.activePlayer
    # Draw card
    if not firstTurn? or not firstTurn
      @drawCards(@model.state.activePlayer, CARDS_DRAWN_PER_TURN)

  assignNextActivePlayer: ->
    if @model.state.activePlayer?
      @model.state.activePlayer = @getNextPlayer(@model.state.activePlayer).userId
    else
      @model.state.activePlayer = @getRandomPlayer().userId

  drawCards: (userId, count) ->
    cards = @players[userId].drawCards(count)
    @emitAllBut userId, 'opponent-draw-cards', userId, cards.map (c) -> c._id
    @emit userId, 'draw-cards', cards
    return cards

  getNextPlayer: (userId)->
    idx = @model.users.indexOf(userId)
    if idx is @model.players.length - 1
      idx = 0
    else
      idx++
    return @players[@model.users[idx]]

  getRandomPlayer: ->
    return @model.players[Math.floor(Math.random() * @model.players.length)]

  getNonActivePlayers: ->
    return @model.users.filter (u) => u isnt @model.state.activePlayer

  getPlayer: (playerId) ->
    return @players[playerId]

  getOtherPlayers: (playerId) ->
    if typeof playerId isnt 'string'
      playerId = playerId._id
    return (p for id, p of @players when id isnt playerId)

  getHero: (heroId) ->
    for _, p of @players
      hero = p.getHero()
      if hero._id is heroId
        return hero
    return null

  getCardHandler: (cardId) ->
    return @cards[cardId]

  getCard: (cardId) ->
    for _, p of @players
      card = p.getCard(cardId)
      if card?
        return card
    return null

  getFieldCards: ->
    fieldCards = []
    for _, p of @players
      fieldCards = fieldCards.concat p.getFieldCards()
    return fieldCards

  sanitizeOpponentData: (player) ->
    out =
      hero: player.getHero() #TODO: Make sure that all hero data is fine for the player to see (secrets and such should be stripped)
      field: player.getFieldCards()
      handSize: player.getHandCards().length # Player does not get to see opponent's cards
      deckSize: player.getDeckCards().length

  getOpponentsData: (user) ->
    others = @model.players.filter (p) -> p.userId isnt user._id
    return others.map((o) => @sanitizeOpponentData(@players[o.userId]))

  getData: (user) ->
    player = @players[user._id]
    out =
      battle:
        state:
          phase:@model.state.phase
      you:
        hero: player.getHero()
        field: player.getFieldCards()
        hand: player.getHandCards()
        deckSize: player.getDeckCards().length # Player doesn't get to know what card is in deck
      opponents: @getOpponentsData(user)

module.exports = Battle
