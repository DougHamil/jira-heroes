HealAction = require './heal'
DamageAction = require './damage'
OverhealAction = require './overheal'
AddModifierAction = require './addmodifier'

###
# This action sets the target's health to the specified amount, using overheal if necessary
###
class SetHealthAction
  constructor: (@source, @target, @newHealth) ->

  enact: (battle)->
    actions = []
    # Overheal if necessary
    if @target.getMaxHealth() isnt @newHealth
      actions.push new AddModifierAction(battle.getNextAbilityId(), @target, {maxHealth:@newHealth - @target.getMaxHealth()})

    healthDelta = @newHealth - @target.health
    if healthDelta > 0
      actions.push new HealAction(@source, @target, healthDelta)
    else if healthDelta < 0
      actions.push new DamageAction(@source, @target, -healthDelta)

    return [null, actions]

module.exports = SetHealthAction
