define ['eventemitter', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (EventEmitter, Animation, GUI, engine, Util) ->
  class BattleCard extends EventEmitter
    constructor: (@cardClass, @card) ->
      super
      @cardSprite = new GUI.Card cardClass, card.damage, card.health, card.status
      @tokenSprite = new GUI.CardToken card, cardClass
      @cardSprite.visible = false
      @tokenSprite.visible = false

    makeCardVisible: ->
      if @cardSprite.visible
        return new Animation()
      else
        # TODO: Create some animation for turning the token back into a card
        @setCardVisible(true)
        return new Animation()

    makeTokenVisible: ->
      if @tokenSprite.visible
        return new Animation()
      else
        # TODO: Create some animation for turning the card into a token
        return new Animation()

    ###
    # enable/disable the interactivity of a card (ie can the player cast/play it?)
    ###
    setCardInteractive: (isInteractive) ->
      if isInteractive
        @cardSprite.onHoverStart => @emit 'card-hover-start', @
        @cardSprite.onHoverEnd => @emit 'card-hover-end', @
        @cardSprite.onMouseDown => @emit 'card-mouse-down', @
        @cardSprite.onMouseUp => @emit 'card-mouse-up', @
      else
        @cardSprite.removeAllInteractions()
    ###
    # enable/disable the interactivity of a token (ie can the player cast/play it?)
    ###
    setTokenInteractive: (isInteractive) ->

    setCardPosition: (position) -> @cardSprite.position = Util.clone(position)
    setTokenPosition: (position) -> @tokenSprite.position = Util.clone(position)
    setCardVisible: (vis) -> @cardSprite.visible = vis
    setTokenVisible: (vis) -> @tokenSprite.visible = vis

    ###
    # Generate the animation for moving a card to a position
    ###
    moveCardTo: (position, animTime, disableInteraction) ->
      animation = new Animation()
      tween = Util.spriteTween @cardSprite, @cardSprite.position, position, animTime
      if disableInteraction
        @setCardInteractive(false)
        tween.onComplete => @setCardInteractive(true)
      animation.addTweenStep tween, 'card-move'
      return animation

    moveTokenTo: (position, animTime, disableInteraction) ->
      animation = new Animation()
      tween = Util.spriteTween @tokenSprite, @tokenSprite.position, position, animTime
      if disableInteraction
        @setTokenInteractive(false)
        tween.onComplete => @setTokenInteractive(true)
      animation.addTweenStep tween, 'token-move'
      return animation

    # Getters make me feel better
    getCardSprite: -> return @cardSprite
    getTokenSprite: -> return @tokenSprite
    getCard: -> return @card
    getCardClass: -> return @cardClass
    getCardId: -> return @card._id
    getId: -> return @card._id
