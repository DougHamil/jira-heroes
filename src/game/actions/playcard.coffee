class PlayCardAction
  constructor: (@cardModel) ->

  enact: (battle)->
    cardHandler = battle.getCardHandler(@cardModel._id)
    cardHandler.registerPassiveAbilities()
    @cardModel.position = 'field'
    PAYLOAD =
      type: 'play-card'
      card: @cardModel
    return [PAYLOAD]

module.exports = PlayCardAction
