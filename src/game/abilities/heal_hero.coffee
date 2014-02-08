HealAction = require '../actions/heal'

class HealHeroAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data

  getValidTargets: (battle) -> return null

  getTargets: (battle, target) ->
    targets = []
    player = battle.getPlayerOf(@source)
    hero = battle.getHero(player)
    targets.push hero
    return targets

  cast: (battle, target) ->
    hero = battle.getHeroOfPlayer(battle.getPlayerOf(@source))
    return [new HealAction(@source, hero, @data.amount)]

module.exports = HealHeroAbility
