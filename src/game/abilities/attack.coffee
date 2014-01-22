DamageAction = require '../actions/damage'

class AttackAbility
  constructor: (@model) ->
    @source = @model.sourceCard

  cast: (battle, target) ->
    actions = []
    actions.push new DamageAction(@source, target, (@source.damage + @source.damageBuff))
    # If the target is not frozen, then the target will strike back
    if not target.status? or 'frozen' not in target.status
      actions.push new DamageAction(target, @source, (target.damage + target.damageBuff))
    return actions

module.exports = AttackAbility
