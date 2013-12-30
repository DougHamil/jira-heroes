async = require 'async'
Errors = require './errors'
Battle = require './battle'
Battles = require '../../lib/models/battle'

###
BattleManager maintains a cache of all active battles and allows easy
look-up of existing battles and creation of new battles
###
class BattleManager
  @battles: {}
  @get: (id, cb) ->
    if @battles[id]?
      cb null, @battles[id]
    else
      # Load the battle model
      Battles.get id, (err, model) =>
        if err?
          cb err
        else if not model?
          cb Errors.INVALID_BATTLE
        else
          battle = new Battle model
          @battles[model._id] = battle
          cb null, battle

module.exports = BattleManager
