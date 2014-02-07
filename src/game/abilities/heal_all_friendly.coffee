HealAction = require '../actions/heal'
CastCardAction = require '../actions/castcard'

###
# This ability heals all friendly units (and optionally hero) on cast
###
class HealAllFriendlyAbility
  constructor: (@model) ->
    @amount = @model.data.amount
    @healHero = @model.data.healHero
    @sourceModel = @model.source

  getValidTargets: (battle) -> return null

  getTargets: (battle, target) ->
    targets = []
    player = battle.getPlayerOfCard(@sourceModel)
    for minion in battle.getFieldCards(player)
      targets.push minion
    if @healHero? and @healHero
      hero = battle.getHero(player)
      targets.push hero
    return targets

  cast: (battle, target) ->
    player = battle.getPlayerOfCard(@sourceModel)
    actions = []
    for minion in battle.getFieldCards(player)
      actions.push new HealAction(@sourceModel, minion, @amount)
    if @healHero? and @healHero
      hero = battle.getHero(player)
      actions.push new HealAction(@sourceModel, hero, @amount)
    return actions

module.exports = HealAllFriendlyAbility
