EnergyAction = require './energy'
PermStatusAddAction = require './permstatusadd'

class PlayCardAction
  constructor: (@cardModel, @cardClass) ->

  enact: (battle)->
    cardHandler = battle.getCardHandler(@cardModel._id)
    player = battle.getPlayer(@cardModel.userId)
    @cardModel.position = 'field'

    # Passive abilities, when registered, may generate activities
    actions = cardHandler.registerPassiveAbilities()
    actions.push new EnergyAction(player, -@cardModel.getEnergy())
    # The rush trait indicates a card can be used immediately on the turn of play
    if 'rush' not in @cardClass.traits
      actions.push new PermStatusAddAction(@cardModel, 'sleeping')
    if 'taunt' in @cardClass.traits
      actions.push new PermStatusAddAction(@cardModel, 'taunt')
    PAYLOAD =
      type: 'play-card'
      player: @cardModel.userId
      card: @cardModel
    return [PAYLOAD, actions]

module.exports = PlayCardAction
