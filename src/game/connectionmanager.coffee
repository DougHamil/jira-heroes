Errors = require './errors'
DeckModel = require '../models/deck'
CardCache = require './cardcache'

###
ConnectionManager handles initial socket connections by routing battle hosting and joining
to the proper Battle instance
###
class ConnectionManager
  constructor: (@battleManager, @socket, @user) ->
    @socket.on 'join', (deckId, battleId, cb) =>
      @onJoin(deckId, battleId, cb)
    @socket.on 'host', (deckId, cb) =>
      @onHost(deckId, cb)

  ###
  # Called when a user wants to create a new battle, automatically joins user to battle upon creation
  ###
  onHost: (deckId, cb) ->
    if @battle?
      cb Errors.ALREADY_IN_BATTLE
    else
      @battleManager.createBattle (err, battle) =>
        if err?
          cb err
        else
          @onJoin(deckId, battle.id, cb)

  ###
  # Called when a user wants to join a specific battle with a specific deck.
  ###
  onJoin: (deckId, battleId, cb) ->
    if @battle?
      cb Errors.ALREADY_IN_BATTLE
    else
      DeckModel.findOne {id:deckId}, (err, deck) =>
        if err?
          cb err
        else
          @deck = deck
          if not @deck?
            cb Errors.INVALID_DECK
          else
            # Load all cards
            CardCache.load deck.cards, (err, cards) =>
              if err?
                cb err
              else
                # Get and join battle
                @battleManager.getBattle battleId, (err, battle) =>
                  if err?
                    cb err
                  else
                    @battle = battle
                    @battle.onPlayerJoined @user, deck.hero, cards
                    cb null, @battle

    ###
    # Called when a user wants to connect to battle that he has already joined
    ###
    onConnect: (battleId, cb) ->
      if @battle?
        cb Errors.ALREADY_IN_BATTLE
      else
        @battleManager.getBattle battleId, (err, battle) =>
          if err?
            cb err
          else
            @battle = battle
            @battle.onPlayerConnected @user, @socket
            cb null, @battle

module.exports = ConnectionManager
