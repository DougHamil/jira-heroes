AddModifierAction = require './addmodifier'
HealAction = require './heal'

###
# This action increases a target's maximum health to the specified amount and heals
# the target by the increase in max health
###
class BoostHealthAction
  constructor: (@source, @modId, @target, @newMaxHealth) ->

  enact: (battle)->
    actions = []
    # Add a modifier to increase target's max health to the specified level
    maxHealthDiff = @newMaxHealth - @target.getMaxHealth()
    if maxHealthDiff > 0
      actions.push new AddModifierAction(@modId, @target, {maxHealth:maxHealthDiff})
      # Heal the target by the increase in max health
      actions.push new HealAction(@source, @target, maxHealthDiff)
    return [null, actions]

module.exports = BoostHealthAction
