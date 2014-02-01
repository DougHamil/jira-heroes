class PlayHeroAction
  constructor: (@heroModel, @heroClass) ->

  enact: (battle)->
    heroHandler = battle.getHeroHandler(@heroModel._id)

    # Passive abilities, when registered, may generate activities
    actions = heroHandler.registerPassiveAbilities()

    PAYLOAD =
      type: 'play-hero'
      player: @heroModel.userId
      hero: @heroModel
    return [PAYLOAD, actions]

module.exports = PlayHeroAction
