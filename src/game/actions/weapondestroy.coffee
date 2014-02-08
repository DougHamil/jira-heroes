class WeaponDestroyAction
  constructor: (@hero) ->

  enact: (battle) ->
    actions = []
    @hero.weapon = null
    PAYLOAD =
      type: 'weapon-destroy'
      hero: @hero._id
    return [PAYLOAD, actions]

module.exports = WeaponDestroyAction
