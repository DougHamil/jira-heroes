define ['battle/animation', 'battle/row', 'eventemitter', 'gui', 'engine', 'util', 'pixi'], (Animation, Row, EventEmitter, GUI, engine, Util) ->
  class PlayerField extends EventEmitter
    constructor: (config, @uiLayer) ->
      super
      @animTime = config.animationTime
      @hoverOffset = config.hoverOffset
      @fieldArea = config.fieldArea
      @origin = config.origin
      @interactionEnabled = config.interactionEnabled
      @tokens = {}
      @tokenRow = new Row config.origin, GUI.CardToken.Width, config.padding

    addCard: (battleCard, doAnimation, enableInteraction) ->
      doAnimation = true if not doAnimation?
      @tokens[battleCard.getId()] = battleCard
      animation = null
      if doAnimation
        animation = new Animation()
        animation.addAnimationStep battleCard.moveCardAndTokenTo(@tokenRow.getNextPosition(), @animTime, false), 'token-moved'
        animation.addAnimationStep =>
          return battleCard.makeTokenVisible()

        # Position the card sprite next to the token
        animation.on 'complete', =>
          battleCard.updatePopupPosition()
          if enableInteraction
            @_addTokenInteraction(battleCard)
          else
            @_addPopupInteraction(battleCard)
      else
        battleCard.setTokenVisible(true)
        battleCard.setCardVisible(false)
        battleCard.setTokenPosition(@tokenRow.getNextPosition())
        if enableInteraction
          @_addTokenInteraction(battleCard)
        else
          @_addPopupInteraction(battleCard)
        battleCard.updatePopupPosition()
      @tokenRow.add battleCard
      return animation

    removeCard: (battleCard) ->
      delete @tokens[battleCard.getId()]
      @tokenRow.remove battleCard
      @_removeTokenInteraction(battleCard)

    hasCard: (card) -> return @tokens[card.getId()]?

    onMouseUp: (position) ->
      @_endTokenTarget(position) if @targetSourceCard?

    update: ->
      if @targetSourceCard? and @targetSourceCard.getTokenSprite().visible
        if @targettingGraphics?
          @uiLayer.removeChild @targettingGraphics
        @targettingGraphics = Util.drawArrow(@targetSourceCard.getTokenSprite().getCenterPosition(), @uiLayer.stage.getMousePosition())
        @uiLayer.addChild @targettingGraphics

    buildReorderAnimation: ->
      animation = new Animation()
      animation.addAnimationStep =>
        innerAnim = new Animation()
        # Use the row to determine what the new positions should be
        newPositions = @tokenRow.getElementPositions()
        newPositionsByCardId = {}
        for pos in newPositions
          newPositionsByCardId[pos.element.getId()] = pos.position
        updateBattleCard = (bCard) => => bCard.updatePopupPosition()
        for cardId, battleCard of @tokens
          cardSprite = battleCard.getTokenSprite()
          currentPosition = cardSprite.position
          newPosition = newPositionsByCardId[cardId]
          if not Util.pointsEqual(currentPosition, newPosition)
            subAnim = new Animation()
            subAnim.addAnimationStep battleCard.moveTokenTo(newPosition, @animTime, true), 'token-reorder'
            subAnim.on 'complete', updateBattleCard(battleCard)
            innerAnim.addAnimationStep subAnim
        return innerAnim
      return animation

    containsPoint: (point) ->
      point = Util.pointSubtract(point, @origin)
      point.x += GUI.CardToken.Width/2
      point.y += GUI.CardToken.Height/2
      return @fieldArea.contains(point.x, point.y)

    getBattleCards: -> (card for id, card of @tokens)

    _removeTokenInteraction: (battleCard) ->
      battleCard.setCardInteractive(false)
      battleCard.setTokenInteractive(false)
      battleCard.setCardVisible(false)

    _addPopupInteraction: (battleCard) ->
      battleCard.setTokenInteractive(true)
      battleCard.on 'token-hover-start', =>
        battleCard.setCardVisible(true)
      battleCard.on 'token-hover-end', =>
        battleCard.setCardVisible(false)

    _addTokenInteraction: (battleCard) ->
      @_addPopupInteraction(battleCard)
      battleCard.on 'token-mouse-down', => @beginTokenTarget(battleCard)

    beginTokenTarget: (battleCard) ->
      @targetSourceCard = battleCard

    _endTokenTarget: (position) ->
      @emit 'token-target', @targetSourceCard, position
      @targetSourceCard = null
      if @targettingGraphics?
        @uiLayer.removeChild @targettingGraphics
        @targettingGraphics = null
