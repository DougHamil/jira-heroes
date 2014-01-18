EnergyAction = require './energy'
CardStatusAddAction = require './cardstatusadd'

class PlayCardAction
  constructor: (@cardModel, @cardClass) ->

  enact: (battle)->
    cardHandler = battle.getCardHandler(@cardModel._id)
    player = battle.getPlayer(@cardModel.userId)
    cardHandler.registerPassiveAbilities()
    @cardModel.position = 'field'
    actions = []
    actions.push new EnergyAction(player, -@cardClass.energy)
    if 'rush' not in @cardClass.traits
      actions.push new CardStatusAddAction(@cardModel, 'sleeping')
    if 'taunt' in @cardClass.traits
      actions.push new CardStatusAddAction(@cardModel, 'taunt')
    PAYLOAD =
      type: 'play-card'
      player: @cardModel.userId
      card: @cardModel
    return [PAYLOAD, actions]

module.exports = PlayCardAction
