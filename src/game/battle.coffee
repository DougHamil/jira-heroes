Errors = require './errors'
CardCache = require '../../lib/models/cardcache'
PlayerHandler = require './playerhandler'
CardHandler = require './cardhandler'

CARDS_DRAWN_PER_TURN = 1 # Number of cards to draw each turn
INITIAL_CARD_COUNT = 3 # Second turn player gets 3 cards to start

class Battle
  constructor: (@model) ->
    @players = {}
    @sockets = {}
    @field = {}
    for player in @model.players
      cardsById = {}
      for card in player.deck.cards
        cardsById[card._id] = card
      player.cards = cardsById
      @players[player.userId] = new PlayerHandler(@, player)
      @registerPlayer(player.userId, @players[player.userId])

  registerPlayer: (userId, handler) ->
    handler.on 'ready', @onReady(userId)                      # Player is in battle and wishes to start
    handler.on 'play-card', @onPlayCard(userId)               # Deploy card from hand to field
    handler.on 'end-turn', @onEndTurn(userId)                 # Turn over
    handler.on 'use-card-on-card', @onUseCardOnCard(userId)   # Player used a card, targeting another card
    handler.on 'use-card-on-hero', @onUseCardOnHero(userId)   # Player used a card, targeting a hero

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

  # Called when a player used a card, targeting a hero
  onUseCardOnHero: (userId) ->
    (card, targetHero, action) ->
      @emitAllButActive 'opponent-use-card-on-hero', userId, card, targetHero, action

  # Called when a player used a card, targeting another card
  onUseCardOnCard: (userId) ->
    (card, targetCard, action) ->
      @emitAllButActive 'opponent-use-card-on-card', userId, card, targetCard._id, action

  # Called when the player has played a card
  onPlayCard: (userId) ->
    (card) =>
      @emitAllButActive 'opponent-play-card', userId, card

  # Called when the player has completed his turn
  onEndTurn: (userId) ->
    () =>
      @nextTurn()

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
    if firstTurn? and not firstTurn
      @assignNextActivePlayer()
    # Update the cards on the field
    fieldCards = @getFieldCards()
    CardHandler.updateFieldCardsOnTurn fieldCards
    @emitActive 'your-turn', fieldCards
    @emitAllButActive 'opponent-turn', @model.state.activePlayer, fieldCards
    # Draw card
    if firstTurn? and not firstTurn
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

  getHero: (heroId) ->
    for _, p of @players
      hero = p.getHero()
      if hero._id is heroId
        return hero
    return null

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
