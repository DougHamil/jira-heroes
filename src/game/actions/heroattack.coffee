PermStatusAddAction = require './permstatusadd'
WeaponDurabilityAction = require './weapondurability'

class HeroAttackAction
  constructor: (@source, @target) ->

  enact: (battle)->
    actions = []
    if 'used' not in @source.getStatus()
      actions.push new PermStatusAddAction(@source, 'used')
    if @source.weapon?
      actions.push new WeaponDurabilityAction(@source, -1)
    PAYLOAD =
      type: 'hero-attack'
      source: @source._id
      target: @target._id
    return [PAYLOAD, actions]

module.exports = HeroAttackAction
