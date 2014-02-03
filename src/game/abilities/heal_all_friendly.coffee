HealAction = require '../actions/heal'
CastCardAction = require '../actions/castcard'

###
# This ability heals all friendly units (and optionally hero) on cast
###
class HealAllFriendlyAbility
  constructor: (@model) ->
    @amount = @model.data.amount
    @healHero = @model.data.healHero
    @cardModel = @model.sourceCard

  getValidTargets: (battle) -> return null

  getTargets: (battle, target) ->
    targets = []
    player = battle.getPlayerOfCard(@cardModel)
    for minion in battle.getFieldCards(player)
      targets.push minion
    if @healHero? and @healHero
      hero = battle.getHero(player)
      targets.push hero
    return targets

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
