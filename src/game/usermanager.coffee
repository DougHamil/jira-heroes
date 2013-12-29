Errors = require './errors'
DeckModel = require '../models/deck'
CardCache = require './cardcache'
BattleCache = require './battlecache'

###
ConnectionManager handles initial socket connections by routing battle hosting and joining
to the proper Battle instance
###
class UserManager
  constructor: (@battleManager, @socket, @user) ->
    @socket.on 'join', (deckId, battleId, cb) =>
      @onJoin(deckId, battleId, cb)
    @socket.on 'host', (deckId, cb) =>
      @onHost(deckId, cb)

  ###
  # Called when a user wants to connect to a battle
  ###
  onConnect: (battleId, cb) ->
    if @battle?
      # User is already in a battle
      cb Errors.ALREADY_IN_BATTLE
    else if battleId isnt @user.activeBattle
      # The user is not joined in this battle
      cb Errors.INVALID_BATTLE
    else
      BattleCache.get battleId, (err, @battle) =>
        if err?
          cb err
        else
          @deck = @battle.getDeckForUser @user
            @deck = deck
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

module.exports = ConnectionManager
