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

    animateModifierAdd: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        console.log @card.getStatus()
        @getTokenSprite().setFrozen('frozen' in @card.getStatus())
        @getTokenSprite().setTaunt('taunt' in @card.getStatus())
        @getTokenSprite().setSleeping('sleeping' in @card.getStatus())
        @getTokenSprite().setDamage(@card.getDamage())
      return animation

    animateModifierRemove: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setFrozen('frozen' in @card.getStatus())
        @getTokenSprite().setTaunt('taunt' in @card.getStatus())
        @getTokenSprite().setSleeping('sleeping' in @card.getStatus())
        @getTokenSprite().setDamage(@card.getDamage())
      return animation

    animateStatusAdd: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        console.log @card.getStatus()
        @getTokenSprite().setFrozen('frozen' in @card.getStatus())
        @getTokenSprite().setTaunt('taunt' in @card.getStatus())
        @getTokenSprite().setSleeping('sleeping' in @card.getStatus())
      return animation

    animateStatusRemove: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setFrozen('frozen' in @card.getStatus())
        @getTokenSprite().setTaunt('taunt' in @card.getStatus())
        @getTokenSprite().setSleeping('sleeping' in @card.getStatus())
      return animation

    animateCasted: ->
      animation = new Animation()
      sprite = @getCardSprite()
      animation.addTweenStep Util.fadeSpriteTween(sprite, 0, 500)
      animation.on 'complete', =>
        @setTokenInteractive(false)
        @setCardInteractive(false)
        @setCardVisible(false)
        @setTokenVisible(false)
      return animation

    animateDestroyed: ->
      animation = new Animation()
      sprite = @getTokenSprite()
      animation.addTweenStep Util.fadeSpriteTween(sprite, 0, 500)
      animation.on 'complete', =>
        @setTokenInteractive(false)
        @setCardVisible(false)
        @setTokenVisible(false)
        @getTokenSprite().parent.removeChild(@getTokenSprite())
      return animation

    animateHealed: ->
      animation = new Animation()
      animation.on 'complete', => @getTokenSprite().setHealth(@card.health)
      return animation

    animateDamaged:->
      animation = new Animation()
      jitterSteps = 5
      sprite = @getTokenSprite()
      initialPosition = Util.clone(sprite.position)
      for i in [0...5]
        animation.addTweenStep ->
          return Util.spriteTween sprite, sprite.position, Util.pointJitter(sprite.position, 10), 50
      animation.addTweenStep =>
        @getTokenSprite().setHealth(@card.health)
        return Util.spriteTween sprite, sprite.position, initialPosition, 50
      return animation

    flipCard: ->
      buildAnim = =>
        innerAnim = new Animation()
        @cardSprite.scale.x = 0
        @cardSprite.position = @flippedCardSprite.position
        sprite = @cardSprite
        flippedSprite = @flippedCardSprite
        tweenOut = new TWEEN.Tween({scale:1.0}).to({scale:0}, 500).onUpdate ->
          flippedSprite.scale.x = @scale
        tweenIn = new TWEEN.Tween({scale:0}).to({scale:1.0}, 500).onUpdate ->
          sprite.scale.x = @scale
        innerAnim.addTweenStep tweenOut, 'flipOut'
        innerAnim.addTweenStep tweenIn, 'flipIn'
        innerAnim.on 'complete-step-flipOut', =>
          @setFlippedCardVisible(false)
          @setCardVisible(true)
        return innerAnim
      animation = new Animation()
      animation.addAnimationStep buildAnim
      return animation

    makeCardVisible: ->
      cardSprite = @getAvailableCardSprite()
      if cardSprite.visible
        return new Animation()
      else
        # TODO: Create some animation for turning the token back into a card
        @setCardVisible(true)
        @setTokenVisible(false)
        return new Animation()

    makeTokenVisible: ->
      if @tokenSprite.visible
        return new Animation()
      else
        # TODO: Create some animation for turning the card into a token
        @setTokenVisible(true)
        @setCardVisible(false)
        @setFlippedCardVisible(false)
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
        @clearEvent 'card-hover-start'
        @clearEvent 'card-hover-end'
        @clearEvent 'card-mouse-down'
        @clearEvent 'card-mouse-up'

    ###
    # enable/disable the interactivity of a token (ie can the player cast/play it?)
    ###
    setTokenInteractive: (isInteractive) ->
      tokenSprite = @getTokenSprite()
      if isInteractive
        tokenSprite.onHoverStart => @emit 'token-hover-start', @
        tokenSprite.onHoverEnd => @emit 'token-hover-end', @
        tokenSprite.onMouseDown => @emit 'token-mouse-down', @
        tokenSprite.onMouseUp => @emit 'token-mouse-up', @
      else
        tokenSprite.removeAllInteractions()
        @clearEvent 'token-hover-start'
        @clearEvent 'token-hover-end'
        @clearEvent 'token-mouse-down'
        @clearEvent 'token-mouse-up'


    ###
    # Generate the animation for moving a card to a position
    ###
    moveCardTo: (position, animTime, disableInteraction) ->
      animation = new Animation()
      cardSprite = @getAvailableCardSprite()
      buildTween = ->
        tween = Util.spriteTween cardSprite, cardSprite.position, position, animTime
        if disableInteraction
          @setCardInteractive(false)
          tween.onComplete => @setCardInteractive(true)
        return tween
      animation.addTweenStep buildTween, 'card-move'
      return animation

    moveFlippedCardTo: (position, animTime, disableInteraction) ->
      animation = new Animation()
      cardSprite = @getFlippedCardSprite()
      buildTween = ->
        tween = Util.spriteTween cardSprite, cardSprite.position, position, animTime
        if disableInteraction
          @setCardInteractive(false)
          tween.onComplete => @setCardInteractive(true)
        return tween
      animation.addTweenStep buildTween, 'card-move'
      return animation

    moveTokenTo: (position, animTime, disableInteraction) ->
      animation = new Animation()
      tween = Util.spriteTween @tokenSprite, @tokenSprite.position, position, animTime
      if disableInteraction
        @setTokenInteractive(false)
      animation.addTweenStep tween, 'token-move'
      if disableInteraction
        animation.on 'complete', =>
          @setTokenInteractive(true)
      return animation

    buildCastAnimation: (target) ->
      console.log target
      animation = new Animation()
      tween = null
      # TODO: Figure out good cast animation system with particles and stuff
      if not target?
        tween = Util.spriteTween @tokenSprite, {rotation:@tokenSprite.rotation}, {rotation:@tokenSprite.rotation * 3}, 1000
      else
        tween = Util.spriteTween @tokenSprite, @tokenSprite.position, target.getPosition(), 500
      animation.addTweenStep tween, 'cast'
      return animation

    containsPoint: (point) ->
      if @isTokenVisible()
        return @getTokenSprite().contains(point)
      else if @isCardVisible()
        return @getAvailableCardSprite().contains(point)
      return false

    # Setters make me feel better
    setCardPosition: (position) ->
      cardSprite = @getAvailableCardSprite()
      cardSprite.position = Util.clone(position)
    setTokenPosition: (position) -> @tokenSprite.position = Util.clone(position)
    setFlippedCardVisible: (vis) -> @flippedCardSprite.visible = vis
    setCardVisible: (vis) ->
      cardSprite = @getAvailableCardSprite()
      cardSprite.visible = vis
      if cardSprite isnt @getFlippedCardSprite()
        @getFlippedCardSprite.visible = !vis
    setTokenVisible: (vis) ->
      @tokenSprite.visible = vis if @tokenSprite?
    setCard:(cardClass, card) ->
      @card = card
      @hasCard = true
      @cardClass = cardClass
      @cardSprite = new GUI.Card cardClass, card.damage, card.health, card.status
      @tokenSprite = new GUI.CardToken card, cardClass
      @cardSprite.visible = false
      @tokenSprite.visible = false

    # Getters make me feel better
    requiresTarget: -> return @hasCard and @cardClass.playAbility? and (not @cardClass.playAbility.requiresTarget? or @cardClass.playAbility.requiresTarget)
    isCardVisible: -> return @cardSprite.visible
    isTokenVisible: -> return @tokenSprite.visible
    isMinionCard: -> return @hasCard and not @cardClass.playAbility?
    isSpellCard: -> return @hasCard and @cardClass.playAbility?
    getFlippedCardSprite: -> return @flippedCardSprite
    getAvailableCardSprite: -> return if @hasCard then @cardSprite else @flippedCardSprite
    getCardSprite: -> return @cardSprite
    getCardPosition: -> return @getAvailableCardSprite().position
    getTokenSprite: -> return @tokenSprite
    getCard: -> return @card
    getCardClass: -> return @cardClass
    getCardId: -> return @cardId
    getId: -> return @cardId
