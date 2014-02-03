HealAction = require '../actions/heal'

class HealHeroAbility
  constructor: (@model) ->
    @source = @model.sourceCard
    @data = @model.data

  getValidTargets: (battle) -> return null

  cast: (battle, target) ->
    hero = battle.getHeroOfPlayer(battle.getPlayerOfCard(@source))
    return [new HealAction(@source, hero, @data.amount)]

module.exports = HealHeroAbility
