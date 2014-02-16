CastPassiveAction = require '../../actions/castpassive'
SetHealthAction = require '../../actions/sethealth'
Errors = require '../../errors'

###
# Set the health of the target equal to its current damage
###
class HealthFromDamageAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data

  getValidTargets: (battle) ->
    return battle.getPlayerHandler(@source.userId).getFieldCards()

  cast: (battle, target) ->
    if not target? or not target.isCard or target.userId isnt @source.userId
      throw Errors.INVALID_TARGET
    return [new SetHealthAction(@source, target, target.getDamage())]

module.exports = HealthFromDamageAbility
