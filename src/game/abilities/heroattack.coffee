DamageAction = require '../actions/damage'
HeroAttackAction = require '../actions/heroattack'

class HeroAttackAbility
  constructor: (@model) ->
    @source = @model.source

  getValidTargets: (battle) ->
    targets = []
    for fieldCard in battle.getFieldCards()
      targets.push fieldCard
    for hero in battle.getHeroes()
      if hero isnt @model
        targets.push hero
    return targets

  cast: (battle, target) ->
    actions = []
    actions.push new HeroAttackAction(@source, target)
    actions.push new DamageAction(@source, target, @source.getDamage())
    # If the target is not frozen, then the target will strike back
    if 'frozen' not in target.getStatus()
      actions.push new DamageAction(target, @source, target.getDamage())
    return actions

module.exports = HeroAttackAbility
