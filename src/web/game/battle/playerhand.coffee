define ['battle/animation', 'battle/row', 'gui', 'engine', 'util', 'pixi'], (Animation, Row, GUI, engine, Util) ->
  class PlayerHand
    constructor: (origin, padding, @animTime) ->
      @cards = {}
      @cardRow = new Row origin, GUI.Card.Width, padding

    addCard: (battleCard, doAnimation) ->
      doAnimation = true if not doAnimation? # default to true
      @cards[battleCard.getId()] = battleCard
      animation = null
      if doAnimation
        animation = new Animation()
        animation.addAnimationStep battleCard.makeCardVisible(), 'card-visible'
        animation.addAnimationStep battleCard.moveCardTo(@cardRow.getNextPosition(), @animTime, false), 'card-moved'
      else
        battleCard.setCardVisible(true)
        battleCard.setTokenVisible(false)
        battleCard.setCardPosition(@cardRow.getNextPosition())
      @cardRow.add battleCard
      return tweens

    buildReorderTweens: ->
      tweens = []
      # Use the row to determine what the new positions should be
      newPositions = @cardRow.getElementPositions()
      newPositionsByCardId = {}
      for pos in newPositions
        newPositionsByCardId[pos.element.getId()] = pos.position
      for cardId, battleCard in @cards
        cardSprite = battleCard.getCardSprite()
        currentPosition = cardSprite.position
        newPosition = newPositionsByCardId[cardId]
        if not Util.pointsEqual(currentPosition, newPosition)
          tweens = tweens.concat(battleCard.moveCardTo(newPosition, @animTime, false))
      return tweens
