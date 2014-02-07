DamageAction = require '../actions/damage'
AttackAction = require '../actions/attack'

class AttackAbility
  constructor: (@model) ->
    @source = @model.source

  getValidTargets: (battle) ->
    targets = []
    for fieldCard in battle.getFieldCards()
      targets.push fieldCard
    for hero in battle.getHeroes()
      targets.push hero
    return targets

  cast: (battle, target) ->
    actions = []
    actions.push new AttackAction(@source, target)
    actions.push new DamageAction(@source, target, @source.getDamage())
    # If the target is not frozen, then the target will strike back
    if 'frozen' not in target.getStatus()
      actions.push new DamageAction(target, @source, target.getDamage())
    return actions

module.exports = AttackAbility
