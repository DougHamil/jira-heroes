###
# This action is invoked at the end of each turn
# It should remove all sleeping statuses from field cards
###
module.exports = class EndTurnAction
  constructor: (@player) ->

  enact: (battle) ->
    playerHandler = battle.getPlayer(@player.userId)
    payloads = []
    for card in playerHandler.getFieldCards()
      if 'sleeping' in card.status
        card.status = card.status.filter (s) -> s isnt 'sleeping'
        payload =
          type: 'card-status-remove'
          card: card._id
          status: 'sleeping'
        payloads.push payload
    payload =
      type: 'end-turn'
      player: @player._id
    payloads.push payload
    return [payloads]


