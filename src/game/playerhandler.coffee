{EventEmitter} = require 'events'
CardCache = require '../../lib/models/cardcache'
CardHandler = require './cardhandler'
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
      @socket.on 'end-turn', @onEndTurn()
      @socket.on 'use-card', @onUseCard()
      @socket.on 'test', @onTest()

  onUseCard: ->
    (source, target, cb) =>
      if @model.state.phase == 'game' and @isActive()
        card = @getCard(source)
        if card?
          # Make sure card is either in the player's hand or field
          if card.position is 'hand' or card.position is 'field'
            # Card use targeting a card
            if target.card?
              targetCard = @battle.getCard(target.card)
              # Can only target cards on the field
              if targetCard? and targetCard.position is 'field'
                [err, action] = CardHandler.useCardOnCard @battle, @, card, targetCard
                cb err, action
                if not err?
                  @emit 'use-card-on-card', card, targetCard, action
              else
                cb Errors.INVALID_TARGET
            # Card use targeting a hero
            else if target.hero?
              hero = @battle.getHero(target.hero)
              if hero?
                [err, action] = CardHandler.useCardOnHero @, card, hero
                cb err, action
                if not err?
                  @emit 'use-card-on-hero', card, hero, action
              else
                cb Errors.INVALID_TARGET
            else
              cb Errors.INVALID_ACTION
          else
            cb Errors.INVALID_ACTION
        else
          cb Errors.INVALID_CARD
      else
        cb Errors.INVALID_ACTION

  onEndTurn: ->
    (cb) =>
      if @model.state.phase == 'game' and @isActive()
        @emit 'end-turn'
        cb null
      else
        cb Errors.INVALID_ACTION

  onPlayCard: ->
    (cardId, target, cb) =>
      card = @getCard(cardId)
      if @model.state.phase == 'game' and card? and @isActive() and card.position is 'hand'
        CardCache.get card.class, (err, cardClass) =>
          if err?
            cb err
          else
            [err, actions] = CardHandler.playCard @battle, @, card, cardClass, target
            if err?
              cb err
            else
              @emit 'play-card', card, actions
              cb null, card, actions
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

  getTauntCardsOnField: ->
    return @getFieldCards().filter (c) -> 'taunt' in c.status

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
