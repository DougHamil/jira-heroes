define ['battle/animation', 'battle/row', 'eventemitter', 'gui', 'engine', 'util', 'pixi'], (Animation, Row, EventEmitter, GUI, engine, Util) ->
  class PlayerHand extends EventEmitter
    constructor: (config, @uiLayer) ->
      super
      @hoverOffset = config.hoverOffset
      @animTime = config.animationTime
      @cards = {}
      @cardRow = new Row config.origin, GUI.Card.Width, config.padding

    removeCard: (battleCard) ->
      delete @cards[battleCard.getId()]
      @cardRow.remove battleCard
      @_removeCardInteraction(battleCard)

    addCard: (battleCard, doAnimation, enableInteraction) ->
      doAnimation = true if not doAnimation? # default to true
      @cards[battleCard.getId()] = battleCard
      animation = null
      if doAnimation
        animation = new Animation()
        animation.addAnimationStep battleCard.makeCardVisible(), 'card-visible'
        animation.addAnimationStep battleCard.moveCardTo(@cardRow.getNextPosition(), @animTime, false), 'card-moved'
        if enableInteraction
          animation.on 'complete-step-card-moved', => @_addCardInteraction(battleCard)
      else
        battleCard.setCardVisible(true)
        battleCard.setTokenVisible(false)
        battleCard.setCardPosition(@cardRow.getNextPosition())
        @_addCardInteraction(battleCard) if enableInteraction
      @cardRow.add battleCard
      return animation

    returnCardToHand: (battleCard, disableInteraction) ->
      if @cards[battleCard.getId()]?
        animation = new Animation()
        animation.addAnimationStep battleCard.moveCardTo(@cardRow.getPositionOf(battleCard), @animTime, false), 'card-moved'
        if disableInteraction
          @_removeCardInteraction(battleCard)
          animation.on 'complete-step-card-moved', => @_addCardInteraction(battleCard)
        return animation
      else
        return null

    _removeCardInteraction: (battleCard) ->
      battleCard.setCardInteractive(false)

    _addCardInteraction: (battleCard) ->
      battleCard.setCardInteractive(true)
      battleCard.on 'card-hover-start', =>
        hoveredPosition = Util.clone(@cardRow.getPositionOf(battleCard))
        hoveredPosition.x += @hoverOffset.x
        hoveredPosition.y += @hoverOffset.y
        if battleCard.hoverAnimation?
          battleCard.hoverAnimation.stop()
        battleCard.hoverAnimation = battleCard.moveCardTo(hoveredPosition, @animTime, false)
        battleCard.hoverAnimation.play()
      battleCard.on 'card-hover-end', =>
        handPosition = Util.clone(@cardRow.getPositionOf(battleCard))
        if battleCard.hoverAnimation?
          battleCard.hoverAnimation.stop()
        battleCard.hoverAnimation = battleCard.moveCardTo(handPosition, @animTime, false)
        battleCard.hoverAnimation.play()
      # Minion cards are draggable
      if battleCard.isMinionCard()
        battleCard.on 'card-mouse-down', => @_beginCardDrag(battleCard)
        battleCard.on 'card-mouse-up', => @_endCardDrag(battleCard)
      else if battleCard.isSpellCard()
        battleCard.on 'card-mouse-down', => @_beginCardTarget(battleCard)

    onMouseUp: (position) ->
      @_endCardTarget(position) if @targetSourceCard?

    update: ->
      if @draggingCard?
        cardSprite = @draggingCard.getAvailableCardSprite()
        cardSprite.position = Util.pointSubtract(cardSprite.stage.getMousePosition(), @draggingCardOffset)
      else if @targetSourceCard?
        # Draw arrow from card to mouse
        if @targettingGraphics?
          @uiLayer.removeChild @targettingGraphics
        @targettingGraphics = Util.drawArrow(@targetSourceCard.getCardSprite().getCenterPosition(), @uiLayer.stage.getMousePosition())
        @uiLayer.addChild @targettingGraphics

    _endCardTarget: (position) ->
      @emit 'card-target', @targetSourceCard, position
      @targetSourceCard = null
      if @targettingGraphics?
        @uiLayer.removeChild @targettingGraphics
        @targettingGraphics = null

    _beginCardTarget:(battleCard) ->
      @targetSourceCard = battleCard

    _beginCardDrag: (battleCard) ->
      @draggingCard = battleCard
      @draggingCardOffset = battleCard.getAvailableCardSprite().stage.getMousePosition()
      @draggingCardOffset = Util.pointSubtract(@draggingCardOffset, battleCard.getAvailableCardSprite().position)
      battleCard.hoverAnimation.stop() if battleCard.hoverAnimation?

    _endCardDrag:(battleCard) ->
      @emit 'card-dropped', battleCard, battleCard.getAvailableCardSprite().stage.getMousePosition().clone()
      @draggingCard = null

    buildReorderAnimation: ->
      animation = new Animation()
      # Use the row to determine what the new positions should be
      newPositions = @cardRow.getElementPositions()
      newPositionsByCardId = {}
      for pos in newPositions
        newPositionsByCardId[pos.element.getId()] = pos.position
      for cardId, battleCard of @cards
        cardSprite = battleCard.getCardSprite()
        currentPosition = cardSprite.position
        newPosition = newPositionsByCardId[cardId]
        if not Util.pointsEqual(currentPosition, newPosition)
          animation.addAnimationStep battleCard.moveCardTo(newPosition, @animTime, false), 'card-reorder'
      return animation
