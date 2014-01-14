DamageAction = require '../actions/damage'

class AttackAbility
  constructor: (@source) ->

  cast: (battle, target) ->
    # Simply return a damage action with the target and the card's damage
    return [new DamageAction(@source, target, @source.damage)]

module.exports = AttackAbility
