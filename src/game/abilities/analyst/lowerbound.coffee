DamageAction = require '../../actions/damage'
HealAction = require '../../actions/heal'
OverhealAction = require '../../actions/overheal'
Errors = require '../../errors'

###
# Set all enemy minions health to that of the lowest member among them
###
class LowerBoundAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data

  getValidTargets: (battle) -> return null

  cast: (battle, target) ->
    if target?
      throw Errors.INVALID_TARGET

    fieldCards = []
    actions = []
    for player in battle.getOtherPlayers(@source.userId)
      fieldCards = fieldCards.concat(battle.getPlayerHandler(player).getFieldCards())

    if fieldCards.length > 0
      lowestHealth = fieldCards[0].health
      for card in fieldCards
        if card.health < lowestHealth
          lowestHealth = card.health
      if lowestHealth <= 0
        lowestHealth = 1
      for card in fieldCards
        if card.health > lowestHealth
          actions.push new DamageAction(@source, card, card.health - lowestHealth)

    return actions

module.exports = LowerBoundAbility
