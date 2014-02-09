define ['eventemitter', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (EventEmitter, Animation, GUI, engine, Util) ->
  POPUP_PADDING = 20
  ###
  # A battle card contains the card's sprite, the token sprite and the backside card sprite for a single card
  # It also provides convenience methods for animating the card
  ###
  class BattleCard extends EventEmitter
    constructor: (@cardId, cardClass, card) ->
      super
      @hasCard = false
      @damageIndicator = new GUI.DamageIndicator 0
      @damageIndicator.visible = false
      @flippedCardSprite = new GUI.FlippedCard()
      @flippedCardSprite.visible = false
      if cardClass? and card?
        @setCard(cardClass, card)

    animateAction: (action) ->
      action.animated = true
      switch action.type
        when 'damage'
          return @animateDamaged(action.damage)
        when 'destroy'
          return @animateDestroyed()
        when 'heal'
          return @animateHealed(action.amount)
        when 'overheal'
          return @animateOverhealed(action.amount)
        when 'status-add'
          return @animateStatusAdd(action.status)
        when 'status-remove'
          return @animateStatusRemove(action.status)
        when 'add-modifier'
          return @animateModifierAdd(action.modifier)
        when 'remove-modifier'
          return @animateModifierRemove(action.modifier)
      action.animated = false
      console.log Error("BattleCard cannot animate #{action.type}!")

    animateModifierAdd: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
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
        @getTokenSprite().setUsed('used' in @card.getStatus())
      return animation

    animateStatusRemove: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setFrozen('frozen' in @card.getStatus())
        @getTokenSprite().setTaunt('taunt' in @card.getStatus())
        @getTokenSprite().setSleeping('sleeping' in @card.getStatus())
        @getTokenSprite().setUsed('used' in @card.getStatus())
      return animation

    animateCasted: ->
      animation = new Animation()
      animation.addTweenStep =>
        sprite = @getCardSprite()
        sprite.pivot = {x:0, y:0}
        tween = new TWEEN.Tween({rot:sprite.rotation}).to({rot:(Math.PI/180)*359}, 1000).onUpdate ->
          sprite.rotation = @rot
        tweenFade = Util.fadeSpriteTween(sprite, 0, 1000)
        return [tween, tweenFade]
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

    animateOverhealed: ->
      animation = new Animation()
      animation.on 'complete', => @getTokenSprite().setHealth(@card.health)
      return animation

    animateDamaged: (amount)->
      animation = new Animation()
      animation.addUnchainedAnimationStep @damageIndicator.animate(amount)
      health = if amount? then @getTokenSprite().getHealth() - amount else @card.health
      animation.on 'complete', => @getTokenSprite().setHealth(health)
      return animation

    flipCard: ->
      buildAnim = =>
        innerAnim = new Animation()
        @cardSprite.scale.x = 0
        @cardSprite.position = @flippedCardSprite.position
        sprite = @cardSprite
        flippedSprite = @flippedCardSprite
        tweenOut = new TWEEN.Tween({scale:1.0}).to({scale:0}, 300).easing(TWEEN.Easing.Quadratic.Out).onUpdate ->
          flippedSprite.scale.x = @scale
        tweenIn = new TWEEN.Tween({scale:0}).to({scale:1.0}, 300).easing(TWEEN.Easing.Quadratic.InOut).onUpdate ->
          sprite.scale.x = @scale
        innerAnim.addTweenStep tweenOut, 'flipOut'
        innerAnim.addTweenStep tweenIn, 'flipIn'
        innerAnim.on 'complete-step-flipOut', =>
          @flippedCardSprite.scale = {x:1.0, y:1.0}
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
        animation = new Animation()
        animation.on 'start', =>
          @getTokenSprite().scale = {x:0, y:0}
          @getTokenSprite().anchor = {x:0.5, y:0.5}
          @getAvailableCardSprite().scale = {x:1, y:1}
          @getAvailableCardSprite().anchor = {x:0.5, y:0.5}
          @setTokenVisible(true)
        animation.addTweenStep =>
          tween = Util.scaleSpriteTween @getAvailableCardSprite(), {x:0, y:0}, 400
          return tween
        animation.addTweenStep =>
          tween2 = Util.scaleSpriteTween @getTokenSprite(), {x:1.0, y:1.0}, 400
          tween2.easing(TWEEN.Easing.Elastic.Out)
          return tween2
        animation.on 'complete', =>
          @getCardSprite().scale = {x:1, y:1}
          @getFlippedCardSprite().scale = {x:1, y:1}
          @setTokenVisible(true)
          @setCardVisible(false)
          @setFlippedCardVisible(false)
          @updatePopupPosition()
        return animation

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
      cardSprite = @getAvailableCardSprite()
      cardSprite.visible = false
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
      return =>
        animation = new Animation()
        cardSprite = @getAvailableCardSprite()
        buildTween = ->
          tween = Util.spriteTween cardSprite, cardSprite.position, position, animTime
          tween.easing(TWEEN.Easing.Cubic.Out)
          return tween
        animation.addTweenStep buildTween, 'card-move'
        return animation

    moveCardAndTokenTo: (position, animTime, disableInteraction) ->
      return =>
        animation = new Animation()
        buildTween = =>
          cardSprite = @getAvailableCardSprite()
          tokenSprite = @getTokenSprite()
          tweenCard = Util.spriteTween cardSprite, cardSprite.position, position, animTime
          tweenCard.easing(TWEEN.Easing.Cubic.Out)
          if tokenSprite?
            tweenToken = Util.spriteTween tokenSprite, cardSprite.position, position, animTime
            tweenToken.easing(TWEEN.Easing.Cubic.Out)
          return [tweenCard, tweenToken]
        animation.addTweenStep buildTween, 'card-move'
        return animation

    moveFlippedCardTo: (position, animTime, disableInteraction) ->
      return =>
        animation = new Animation()
        cardSprite = @getFlippedCardSprite()
        buildTween = ->
          tween = Util.spriteTween cardSprite, cardSprite.position, position, animTime
          tween.easing(TWEEN.Easing.Cubic.Out)
          return tween
        animation.addTweenStep buildTween, 'card-move'
        return animation

    moveFlippedCardAndTokenTo: (position, animTime, disableInteraction) ->
      return =>
        animation = new Animation()
        buildTween = =>
          cardSprite = @getFlippedCardSprite()
          tokenSprite = @getTokenSprite()
          tweenCard = Util.spriteTween cardSprite, cardSprite.position, position, animTime
          tweenCard.easing(TWEEN.Easing.Cubic.Out)
          if tokenSprite?
            tweenToken = Util.spriteTween tokenSprite, cardSprite.position, position, animTime
            tweenToken.easing(TWEEN.Easing.Cubic.Out)
          return [tweenCard, tweenToken]
        animation.addTweenStep buildTween, 'card-move'
        return animation

    moveTokenTo: (position, animTime, disableInteraction) ->
      return =>
        animation = new Animation()

        animation.addTweenStep =>
          tween = Util.spriteTween @tokenSprite, @tokenSprite.position, position, animTime
          tween.easing(TWEEN.Easing.Cubic.Out)
          return tween

        if disableInteraction
          animation.on 'start', =>
            @getAvailableCardSprite().visible = false
          animation.on 'complete', =>
            @updatePopupPosition()
        return animation

    updatePopupPosition: ->
      cardSprite = @getCardSprite()
      cardSprite.position = {x:@tokenSprite.position.x + @tokenSprite.width/2 + @cardSprite.width/2 + POPUP_PADDING, y:@tokenSprite.position.y}
      # if popup is off screen, move it to the left of the token
      if (cardSprite.position.x + cardSprite.width) > engine.WIDTH
        cardSprite.position = {x:@tokenSprite.position.x - cardSprite.width - POPUP_PADDING, y:@tokenSprite.position.y}

    buildCastAnimation: (target) ->
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
      @cardSprite = new GUI.Card cardClass, cardClass.damage, cardClass.health, card.getStatus()
      @tokenSprite = new GUI.CardToken card, cardClass
      @damageIndicator.position = {x:0, y:0}
      @tokenSprite.addChild @damageIndicator
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
