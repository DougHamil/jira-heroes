WeaponDestroyAction = require './weapondestroy'

class WeaponDurabilityAction
  constructor: (@hero, @amount) ->

  enact: (battle)->
    actions = []
    @hero.weapon.durability += @amount
    if @hero.weapon.durability <= 0
      actions.push new WeaponDestroyAction(@hero)
    PAYLOAD =
      type: 'weapon-durability'
      hero: @hero._id
      amount: @amount
    return [PAYLOAD, actions]

module.exports = WeaponDurabilityAction
