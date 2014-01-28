define ['battle/animation', 'battle/row', 'gui', 'engine', 'util', 'pixi'], (Animation, Row, GUI, engine, Util) ->
  class PlayerHand
    constructor: (config) ->
      @animTime = config.animationTime
      @cards = {}
      @cardRow = new Row config.origin, GUI.Card.Width, config.padding

    addCard: (battleCard, doAnimation, enableInteraction) ->
      doAnimation = true if not doAnimation? # default to true
      @cards[battleCard.getId()] = battleCard
      animation = null
      if doAnimation
        animation = new Animation()
        animation.addAnimationStep battleCard.makeCardVisible(), 'card-visible'
        animation.addAnimationStep battleCard.moveCardTo(@cardRow.getNextPosition(), @animTime, false), 'card-moved'
        if enableInteraction
      else
        battleCard.setCardVisible(true)
        battleCard.setTokenVisible(false)
        battleCard.setCardPosition(@cardRow.getNextPosition())
        if enableInteraction
          battleCard.setInteractive(true)
      @cardRow.add battleCard
      return animation

    buildReorderAnimation: ->
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
      animation = new Animation()
      animation.addTweenStep tweens, 'reorder-hand'
      return animation
