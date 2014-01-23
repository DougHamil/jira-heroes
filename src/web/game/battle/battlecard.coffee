define ['battle/animation', 'gui', 'engine', 'util', 'pixi'], (Animation, GUI, engine, Util) ->
  class BattleCard
    constructor: (@cardClass, @card) ->
      @cardSprite = new GUI.Card cardClass, card.damage, card.health, card.status
      @tokenSprite = new GUI.CardToken card, cardClass

    makeCardVisible: ->
      if @cardSprite.visible
        return new Animation()
      else
        # TODO: Create some animation for turning the token back into a card
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
