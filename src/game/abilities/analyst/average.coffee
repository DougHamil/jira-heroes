DamageAction = require '../../actions/damage'
HealAction = require '../../actions/heal'
OverhealAction = require '../../actions/overheal'
Errors = require '../../errors'

###
# Average all enemy minions health and set them all to average
# (No overhealing)
###
class AverageAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data
    @overheal = @model.data.overheal? and @model.data.overheal

  getValidTargets: (battle) -> return null

  cast: (battle, target) ->
    if target?
      throw Errors.INVALID_TARGET

    fieldCards = []
    for player in battle.getOtherPlayers(@source.userId)
      fieldCards = fieldCards.concat(battle.getPlayerHandler(player).getFieldCards())
    averageHealth = 0
    for card in fieldCards
      averageHealth += card.health
    averageHealth = Math.floor(averageHealth/fieldCards.length)
    if averageHealth <= 0
      averageHealth = 1

    actions = []
    for card in fieldCards
      if card.health < averageHealth
        if not @overheal
          actions.push new HealAction(@source, card, averageHealth - card.health)
        else
          actions.push new OverhealAction(@source, card, averageHealth - card.health)
      else if card.health > averageHealth
        actions.push new DamageAction(@source, card, card.health - averageHealth)

    return actions

module.exports = AverageAbility
