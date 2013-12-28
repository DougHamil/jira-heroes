async = require 'async'
Errors = require './errors'
Battle = require './battle'
BattleModel = require '../models/battle'

###
BattleManager maintains a cache of all active battles and allows easy
look-up of existing battles and creation of new battles
###
class BattleManager
  constructor: (@userManager, @deckManager)->
    @battles = {}

  createBattle: (cb) ->
    # Create default battle state and save it to get a unique ID
    battle = new Battle(new BattleModel())
    battle.model.save (err) =>
      if err?
        cb err
      else
        @battles[battle.model._id] = battle
        cb null, battle

  loadPlayer: (p, cb) ->
    @userManager.getUser p.playerId, (err, user) ->
      if err?
        cb err
      else
        player = new Player user, p.deck
        cb null, player

  getBattle: (id, cb) ->
    if @battles[id]?
      cb null, @battles[id]
    else
      # Attempt to get from datastore
      BattleModel.findOne {_id:id}, (err, battleModel) =>
        if err?
          cb err
        else if battleModel?
          loadPlayer = (p, cb) =>
          async.map battleModel.players, @loadPlayer.bind(@), (err, players) =>
            if err?
              cb err
            else
              battle = new Battle(battleModel, players)
              @battles[battle.id] = battle
              cb null, battle
        else
          cb "Invalid battle ID: #{id}"

module.exports = BattleManager
