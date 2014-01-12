DamageAction = require '../actions/damage'

class AttackAbility
  constructor: (@battle, @cardHandler) ->

  cast: (target) ->
    # Simply return a damage action with the target and the card's damage
    return [new DamageAction(@cardHandler.model, target, @cardHandler.model.damage)]

module.exports = AttackAbility
