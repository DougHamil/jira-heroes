class DrawCardAction
  constructor: (@player) ->

  enact: (battle) ->
    playerHandler = battle.getPlayerHandler(@player)
    PAYLOAD = null
    if playerHandler.getMaxHandSize() > playerHandler.getHandCards().length
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
    else
      PAYLOAD = null
    return [PAYLOAD]

module.exports = DrawCardAction
