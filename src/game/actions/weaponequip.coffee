class WeaponEquipAction
  constructor: (@hero, @weapon) ->

  enact: (battle) ->
    @hero.weapon = @weapon
    PAYLOAD =
      type: 'weapon-equip'
      hero: @hero._id
      weapon:@weapon
    return [PAYLOAD]

module.exports = WeaponEquipAction
