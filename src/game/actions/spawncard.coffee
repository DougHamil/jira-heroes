PermStatusAddAction = require './permstatusadd'

class SpawnCardAction
  constructor: (@cardModel, @cardClass) ->

  enact:(battle) ->
    cardHandler = battle.getCardHandler(@cardModel._id)
    player = battle.getPlayer(@cardModel.userId)
    playerHandler = battle.getPlayerHandler(@cardModel.userId)
    @cardModel.position = 'field'

    # Passive abilities, when registered, may generate activities
    actions = cardHandler.registerPassiveAbilities()
    # The rush trait indicates a card can be used immediately on the turn of play
    if 'rush' not in @cardClass.traits
      actions.push new PermStatusAddAction(@cardModel, 'sleeping')
    if 'taunt' in @cardClass.traits
      actions.push new PermStatusAddAction(@cardModel, 'taunt')
    if @cardClass.rushAbility? and @cardClass.rushAbility.class? and @cardClass.rushAbility.requiresTarget
      actions.push new PermStatusAddAction(@cardModel, 'can-rush')
    PAYLOAD =
      type: 'spawn-card'
      player: @cardModel.userId
      card: @cardModel
    return [PAYLOAD, actions]

module.exports = SpawnCardAction
