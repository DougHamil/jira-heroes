CardStatusAddAction = require './cardstatusadd'

class PlayCardAction
  constructor: (@cardModel, @cardClass) ->

  enact: (battle)->
    cardHandler = battle.getCardHandler(@cardModel._id)
    cardHandler.registerPassiveAbilities()
    @cardModel.position = 'field'
    actions = []
    if 'rush' not in @cardClass.traits
      actions.push new CardStatusAddAction(@cardModel, 'sleeping')
    if 'taunt' in @cardClass.traits
      actions.push new CardStatusAddAction(@cardModel, 'taunt')
    PAYLOAD =
      type: 'play-card'
      card: @cardModel
    return [PAYLOAD, actions]

module.exports = PlayCardAction
