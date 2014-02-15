CastPassiveAction = require '../../actions/castpassive'
DamageAction = require '../../actions/damage'
DestroyAction = require '../../actions/destroy'
Errors = require '../../errors'

###
# Sacrifice one of your own minions and deal its damage to all minions on the field
# "Straight to Production"
###
class SacrificeAndDamageAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data

  getValidTargets: (battle) -> return battle.getPlayerHandler(@source.userId).getFieldCards()

  cast: (battle, target) ->
    if not target? or not target.isCard or not target.userId is @source.userId
      throw Errors.INVALID_TARGET

    targetDamage = target.getDamage()
    subActions = [new DestroyAction(target, target)]
    targets = []
    for minion in battle.getFieldCards()
      if minion isnt target
        targets.push minion
        subActions.push new DamageAction(target, minion, targetDamage)
    return [new CastPassiveAction(@source, targets, subActions, @model.fx)]

module.exports = SacrificeAndDamageAbility
