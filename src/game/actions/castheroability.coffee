EnergyAction = require './energy'
PermStatusAddAction = require './permstatusadd'

###
# This action is created when the player use's his hero's ability
###
class CastHeroAbilityAction
  constructor: (@heroModel, @heroClass, @targets) ->

  enact: (battle)->
    player = battle.getPlayer(@heroModel.userId)
    actions = []
    actions.push new EnergyAction(player, -@heroModel.getAbilityEnergy())
    if 'ability-used' not in @heroModel.status
      actions.push new PermStatusAddAction(@heroModel, 'ability-used')
    PAYLOAD =
      type: 'cast-hero-ability'
      player: @heroModel.userId
      hero: @heroModel
      targets: @targets
    return [PAYLOAD, actions]

module.exports = CastHeroAbilityAction
