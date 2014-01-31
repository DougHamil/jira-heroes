class DrawCardAction
  constructor: (@player, @handCountModifier) ->
    # Modify the hand count (for instance, if a card is discarded upon casting this action)
    @handCountModifier = 0 if not @handCountModifier?

  enact: (battle) ->
    playerHandler = battle.getPlayerHandler(@player)
    PAYLOAD = null
    if playerHandler.getMaxHandSize() > (playerHandler.getHandCards().length + @handCountModifier)
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
