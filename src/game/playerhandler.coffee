{EventEmitter} = require 'events'
CardCache = require '../../lib/models/cardcache'
Errors = require './errors'

###
# Handles a player within a battle by responding and validating client socket events
# and emitting valid events which the battle can listen to
###
class PlayerHandler extends EventEmitter
  constructor: (@battle, @player) ->
    @model = @battle.model
    @userId = @player.userId

  connect: (@socket) ->
      @socket.on 'ready', @onReady()
      @socket.on 'play-card', @onPlayCard()
      @socket.on 'test', @onTest()

  onPlayCard: ->
    (cardId, cb) =>
      card = @getCard(cardId)
      if @model.state.phase == 'game' and card? and @isActive() and card.position is 'hand'
        CardCache.get card.class, (err, cardClass) =>
          if err?
            cb err
          else
            # Make sure there is enough energy to play this card
            if @player.energy >= cardClass.energy
              @player.energy -= cardClass.energy
              card.position = 'field'
              @emit 'play-card', card
              cb null, card
            else
              cb Errors.NOT_ENOUGH_ENERGY
      else
        cb Errors.INVALID_ACTION

  onReady: ->
      (cb) =>
        if @model.state.phase == 'initial' and @player.userId not in @model.state.playersReady
          @model.state.playersReady.push @player.userId
          cb null
          @emit 'ready'
        else
          cb Errors.INVALID_ACTION

  ###
  # Put player into "test mode" for easy integration testing
  ###
  onTest: ->
    (prop, value, cb) =>
      if global.isTest?
        @player[prop] = value
      cb()

  drawCards: (num) ->
    if not num? then num = 1
    deck = @getDeckCards()
    if deck.length is 0
      return null
    else
      drawnCards = []
      for i in [0..num]
        card = deck[Math.floor(Math.random() * deck.length)]
        card.position = 'hand'
        drawnCards.push card
        deck = deck.filter (c) -> c isnt card
        if deck.length is 0
          return drawnCards
      return drawnCards

  getFieldCards: ->
    return @player.deck.cards.filter (c) -> c.position is 'field'

  getHandCards: ->
    return @player.deck.cards.filter (c) -> c.position is 'hand'

  getDeckCards: ->
    return @player.deck.cards.filter (c) -> c.position is 'deck'

  getCard: (cardId) ->
    card = @player.deck.cards.filter (c) ->
      c._id.toString() is cardId.toString()
    if card.length > 0
      return card[0]
    else
      return null

  getDeck: ->
    return @player.deck

  getHero: ->
    return @player.deck.hero

  hasCard: (cardId) ->
    return (@player.deck.cards.filter (c) -> c._id is cardId).length > 0

  isCardInHand: (cardId) ->
    return cardId in (@getHandCards().map -> (c) -> c._id)

  isActive: ->
    return @model.state.activePlayer is @userId

module.exports = PlayerHandler
