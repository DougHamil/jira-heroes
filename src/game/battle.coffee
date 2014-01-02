Errors = require './errors'
CardCache = require '../../lib/models/cardcache'
PlayerHandler = require './playerhandler'

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
    handler.on 'ready', @onReady(userId)
    handler.on 'play-card', @onPlayCard(userId)

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

  # Called when the player has played a card
  onPlayCard: (userId) ->
    (card) =>
      @emitAllButActive 'card-played', userId, card
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
    @nextTurn()

  nextTurn: ->
    # Pick the next player and set to active
    @assignNextActivePlayer()
    drawnCard = @drawCard(@model.state.activePlayer)
    @emitActive 'your-turn', drawnCard
    @emitAllButActive 'opponent-turn', @model.state.activePlayer
    # Tell opponent that the player drew a card
    if drawnCard?
      @emitAllButActive 'opponent-draw-card'

  assignNextActivePlayer: ->
    if @model.state.activePlayer?
      @model.state.activePlayer = @getNextPlayer(@model.state.activePlayer).userId
    else
      @model.state.activePlayer = @getRandomPlayer().userId

  drawCard: (userId) ->
    @players[userId].drawCards(1)

  getNextPlayer: (userId)->
    idx = @model.users.indexOf(userId)
    if idx is @model.players.length - 1
      idx = 0
    else
      idx++
    return @players[@model.users[idx]]

  getRandomPlayer: ->
    return @model.players[Math.floor(Math.random() * @model.players.length)]

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
      you:
        hero: player.getHero()
        field: player.getFieldCards()
        hand: player.getHandCards()
        deckSize: player.getDeckCards().length # Player doesn't get to know what card is in deck
      opponents: @getOpponentsData(user)

module.exports = Battle
