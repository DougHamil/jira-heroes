class DiscardCardAction
  constructor: (@cardModel) ->

  enact: (battle)->
    cardHandler = battle.getCardHandler(@cardModel._id)
    @cardModel.position = 'discard'
    cardHandler.unregisterPassiveAbilities()
    PAYLOAD =
      type:'discard-card'
      card: @cardModel._id
    return [PAYLOAD]

module.exports = DiscardCardAction
