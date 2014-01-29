EnergyAction = require './energy'

###
# This action is used for spell cards that are casted directly from the player's
# hand. This allows the opponents to know what the card is that was casted as well
# as reduces the casting player's energy
###
class CastCardAction
  constructor: (@cardModel, @cardClass, @targets) ->

  enact: (battle)->
    cardHandler = battle.getCardHandler(@cardModel._id)
    player = battle.getPlayer(@cardModel.userId)
    actions = []
    actions.push new EnergyAction(player, -@cardModel.getEnergy())
    PAYLOAD =
      type: 'cast-card'
      player: @cardModel.userId
      card: @cardModel
      targets: @targets
    return [PAYLOAD, actions]

module.exports = CastCardAction
