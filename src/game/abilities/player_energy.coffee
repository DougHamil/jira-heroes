EnergyAction = require '../actions/energy'
Errors = require '../errors'

class EnergyAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data

  getValidTargets: (battle) -> return null

  cast: (battle, target) ->
    return [new EnergyAction(battle.getPlayerOf(@source), @data.amount)]

module.exports = EnergyAbility
