define ['battle/animation', 'battle/row', 'eventemitter', 'gui', 'engine', 'util', 'pixi'], (Animation, Row, EventEmitter, GUI, engine, Util) ->
  class TokenRow extends EventEmitter
    constructor: (config) ->
      super
      @animTime = config.animationTime
      @hoverOffset = config.hoverOffset
      @tokens = {}
      @tokenRow = new Row config.origin, GUI.Token.Width, config.padding

    addToken: (battleCard, doAnimation, enableInteraction) ->
      doAnimation = true if not doAnimation?
      @tokens[battleCard.getId()] = battleCard
      animation = null
      if doAnimation
        animation = new Animation()
        animation.addAnimationStep battleCard.makeTokenVisible(), 'token-visible'
        animation.addAnimationStep battleCard.moveTokenTo(@tokenRow.getNextPosition(), @animTime, false), 'token-moved'
        if enableInteraction
          animation.on 'complete-step-token-moved', => @_addTokenInteraction(battleCard)
        # Position the card sprite next to the token
        animation.on 'complete', =>
          battleCard.setCardPosition(Util.pointAdd(battleCard.getCardSprite().position, @hoverOffset))
      else
        battleCard.setTokenVisible(true)
        battleCard.setCardVisible(false)
        battleCard.setTokenPosition(@tokenRow.getNextPosition())
        @_addTokenInteraction(battleCard) if enableInteraction
        battleCard.setCardPosition(Util.pointAdd(battleCard.getCardSprite().position, @hoverOffset))
      @tokenRow.add battleCard
      return animation

    removeToken: (battleCard) ->
      delete @tokens[battleCard.getId()]
      @tokenRow.remove battleCard
      @_removeTokenInteraction(battleCard)

    _removeTokenInteraction: (battleCard) ->
      battleCard.setTokenInteractive(false)

    _addTokenInteraction: (battleCard) ->
      battleCard.setTokenInteractive(true)
      battleCard.on 'token-hover-start', =>
        battleCard.setCardVisible(true)
      battleCard.on 'token-hover-end', =>
        battleCard.setCardVisible(false)
      battleCard.on 'token-mouse-down', => @_beginTokenTarget(battleCard)

    _beginTokenTarget: (battleCard) ->
