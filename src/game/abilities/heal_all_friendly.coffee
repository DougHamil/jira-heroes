HealAction = require '../actions/heal'

###
# This ability heals all friendly units (and optionally hero) on cast
###
class HealAllFriendlyAbility
  constructor: (@model) ->
    @amount = @model.data.amount
    @healHero = @model.data.healHero
    @cardModel = @model.sourceCard

  cast: (battle, target) ->
    player = battle.getPlayerOfCard(@cardModel)
    actions = []
    for minion in battle.getFieldCards(player)
      actions.push new HealAction(@cardModel, minion, @amount)
    if @healHero? and @healHero
      hero = battle.getHero(player)
      actions.push new HealAction(@cardModel, hero, @amount)
    return actions

module.exports = HealAllFriendlyAbility
