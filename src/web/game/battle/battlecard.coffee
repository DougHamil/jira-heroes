define ['eventemitter', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (EventEmitter, Animation, GUI, engine, Util) ->
  ###
  # A battle card contains the card's sprite, the token sprite and the backside card sprite for a single card
  # It also provides convenience methods for animating the card
  ###
  class BattleCard extends EventEmitter
    constructor: (@cardId, cardClass, card) ->
      super
      @hasCard = false
      @flippedCardSprite = new GUI.FlippedCard()
      @flippedCardSprite.visible = false
      if cardClass? and card?
        @setCard(cardClass, card)

    makeCardVisible: ->
      cardSprite = @getAvailableCardSprite()
      if cardSprite.visible
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
      cardSprite = @getAvailableCardSprite()
      if isInteractive
        cardSprite.onHoverStart => @emit 'card-hover-start', @
        cardSprite.onHoverEnd => @emit 'card-hover-end', @
        cardSprite.onMouseDown => @emit 'card-mouse-down', @
        cardSprite.onMouseUp => @emit 'card-mouse-up', @
      else
        cardSprite.removeAllInteractions()

    ###
    # enable/disable the interactivity of a token (ie can the player cast/play it?)
    ###
    setTokenInteractive: (isInteractive) ->


    ###
    # Generate the animation for moving a card to a position
    ###
    moveCardTo: (position, animTime, disableInteraction) ->
      animation = new Animation()
      cardSprite = @getAvailableCardSprite()
      tween = Util.spriteTween cardSprite, cardSprite.position, position, animTime
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

    # Setters make me feel better
    setCardPosition: (position) ->
      cardSprite = @getAvailableCardSprite()
      cardSprite.position = Util.clone(position)
    setTokenPosition: (position) -> @tokenSprite.position = Util.clone(position)
    setFlippedCardVisible: (vis) -> @flippedCardSprite.visible = vis
    setCardVisible: (vis) ->
      cardSprite = @getAvailableCardSprite()
      cardSprite.visible = vis
    setTokenVisible: (vis) -> @tokenSprite.visible = vis

    setCard:(cardClass, card) ->
      @card = card
      @hasCard = true
      @cardClass = cardClass
      @cardSprite = new GUI.Card cardClass, card.damage, card.health, card.status
      @tokenSprite = new GUI.CardToken card, cardClass
      @cardSprite.visible = false
      @tokenSprite.visible = false

    # Getters make me feel better
    isCardVisible: -> return @cardSprite.visible
    isTokenVisible: -> return @tokenSprite.visible
    getFlippedCardSprite: -> return @flippedCardSprite
    getAvailableCardSprite: -> return if @hasCard then @cardSprite else @flippedCardSprite
    getCardSprite: -> return @cardSprite
    getTokenSprite: -> return @tokenSprite
    getCard: -> return @card
    getCardClass: -> return @cardClass
    getCardId: -> return @cardId
    getId: -> return @cardId
