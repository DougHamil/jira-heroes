DamageAction = require '../actions/damage'

###
# This ability damages all units and heroes on cast
###
class DamageAllAbility
  constructor: (@model) ->
    @amount = @model.data.amount
    @damageHero = @model.data.damageHero
    @damageMinions = @model.data.damageMinions
    @cardModel = @model.sourceCard

  cast: (battle, target) ->
    actions = []
    for player in battle.players
      if @damageHero? and @damageHero
        hero = battle.getHero(player)
        actions.push new DamageAction(@cardModel, hero, @amount)
      if @damageMinions? and @damageMinions
        for minion in battle.getFieldCards(player)
          actions.push new DamageAction(@cardModel, minion, @amount)
    return actions

module.exports = DamageAllAbility
