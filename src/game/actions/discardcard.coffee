class DiscardCardAction
  constructor: (@cardModel) ->

  enact: (battle)->
    cardHandler = battle.getCardHandler(@cardModel._id)
    @cardModel.position = 'discard'
    # Passive abilities, upon unregistration, may generate actions
    actions = cardHandler.unregisterPassiveAbilities()
    PAYLOAD =
      type:'discard-card'
      card: @cardModel._id
    return [PAYLOAD,actions]

module.exports = DiscardCardAction
