class DrawCardAction
  constructor: (@player) ->

  enact: (battle) ->
    playerHandler = battle.getPlayerHandler(@player)
    card = playerHandler.drawCard()
    if card?
      PAYLOAD =
        type: 'draw-card'
        player: @player.userId
        card: card
        sanitized:
          type: 'draw-card'
          player: @player.userId
          card: card._id
    else
      PAYLOAD = null
    return [PAYLOAD]

module.exports = DrawCardAction
