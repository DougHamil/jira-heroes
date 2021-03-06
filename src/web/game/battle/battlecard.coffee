define ['emitters', 'eventemitter', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (Emitters, EventEmitter, Animation, GUI, engine, Util) ->
  POPUP_PADDING = 20
  HEAL_TEXTURE = PIXI.Texture.fromImage '/media/images/fx/cross.png'
  EXPLODE_TEXTURE_1 = PIXI.Texture.fromImage '/media/images/fx/one.png'
  EXPLODE_TEXTURE_0 = PIXI.Texture.fromImage '/media/images/fx/zero.png'
  CAST_ANIM_TIME = 500
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
        tween = new TWEEN.Tween({rot:sprite.rotation}).to({rot:(Math.PI/180)*359}, CAST_ANIM_TIME).onUpdate ->
          sprite.rotation = @rot
        tweenFade = Util.fadeSpriteTween(sprite, 0, CAST_ANIM_TIME)
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
      animation.on 'start', =>
        emitter = Emitters.SpriteRing {texture:EXPLODE_TEXTURE_1, tint:0x77DDEE, life:[0.5, 1]}
        emitter.p.x = @getTokenSprite().position.x
        emitter.p.y = @getTokenSprite().position.y
        emitter.emit 'once'
        emitter = Emitters.SpriteRing {texture:EXPLODE_TEXTURE_0, vel0: 2.0, vel1:3.0,tint:0x77DDEE, life:[0.5, 1]}
        emitter.p.x = @getTokenSprite().position.x
        emitter.p.y = @getTokenSprite().position.y
        emitter.emit 'once'
      animation.addTweenStep Util.fadeSpriteTween(sprite, 0, 500)
      animation.on 'complete', =>
        @setTokenInteractive(false)
        @setCardVisible(false)
        @setTokenVisible(false)
        @getTokenSprite().parent.removeChild(@getTokenSprite())
      return animation

    animateHealed: (amount)->
      animation = new Animation()
      if amount? and amount > 0
        animation.on 'start', =>
          emitter = Emitters.SpriteRing {texture:HEAL_TEXTURE,tint:0x22B222,life:[0.5,1]}
          emitter.p.x = @getTokenSprite().position.x
          emitter.p.y = @getTokenSprite().position.y
          emitter.emit 'once'
      animation.on 'complete', => @getTokenSprite().setHealth(@card.health)
      return animation

    animateOverhealed: ->
      animation = new Animation()
      animation.on 'start', =>
        emitter = Emitters.SpriteRing {texture:HEAL_TEXTURE,tint:0x22B222,life:[0.5,1]}
        emitter.p.x = @getTokenSprite().position.x
        emitter.p.y = @getTokenSprite().position.y
        emitter.emit 'once'
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
    moveCardTo: (position, animTime, disableInteraction, rotation) ->
      rotation = if rotation? then rotation else 0
      return =>
        animation = new Animation()
        cardSprite = @getAvailableCardSprite()
        buildTween = ->
          tween = new TWEEN.Tween({x:cardSprite.position.x, y:cardSprite.position.y, rot:cardSprite.rotation})
          tween.to({x:position.x, y:position.y, rot:rotation}, animTime)
          tween.easing(TWEEN.Easing.Cubic.Out)
          tween.onUpdate ->
            cardSprite.position.x = @x
            cardSprite.position.y = @y
            cardSprite.rotation = @rot
          return tween
        animation.addTweenStep buildTween, 'card-move'
        return animation

    moveCardAndTokenTo: (position, animTime, disableInteraction, rotation) ->
      rotation = if rotation? then rotation else 0
      return =>
        animation = new Animation()
        buildTween = =>
          cardSprite = @getAvailableCardSprite()
          tokenSprite = @getTokenSprite()
          cardTween = new TWEEN.Tween({x:cardSprite.position.x, y:cardSprite.position.y, rot:cardSprite.rotation})
          cardTween.to({x:position.x, y:position.y, rot:rotation}, animTime)
          cardTween.easing(TWEEN.Easing.Cubic.Out)
          cardTween.onUpdate ->
            cardSprite.position.x = @x
            cardSprite.position.y = @y
            cardSprite.rotation = @rot
          if tokenSprite?
            tokenTween = new TWEEN.Tween({x:tokenSprite.position.x, y:tokenSprite.position.y, rot:tokenSprite.rotation})
            tokenTween.to({x:position.x, y:position.y, rot:rotation}, animTime)
            tokenTween.easing(TWEEN.Easing.Cubic.Out)
            tokenTween.onUpdate ->
              tokenSprite.position.x = @x
              tokenSprite.position.y = @y
              tokenSprite.rotation = @rot
          return [cardTween, tokenTween]
        animation.addTweenStep buildTween, 'card-move'
        return animation

    moveFlippedCardTo: (position, animTime, disableInteraction, rotation) ->
      rotation = if rotation? then rotation else 0
      return =>
        animation = new Animation()
        cardSprite = @getFlippedCardSprite()
        buildTween = ->
          cardTween = new TWEEN.Tween({x:cardSprite.position.x, y:cardSprite.position.y, rot:cardSprite.rotation})
          cardTween.to({x:position.x, y:position.y, rot:rotation}, animTime)
          cardTween.easing(TWEEN.Easing.Cubic.Out)
          cardTween.onUpdate ->
            cardSprite.position.x = @x
            cardSprite.position.y = @y
            cardSprite.rotation = @rot
          return cardTween
        animation.addTweenStep buildTween, 'card-move'
        return animation

    moveFlippedCardAndTokenTo: (position, animTime, disableInteraction, rotation) ->
      rotation = if rotation? then rotation else 0
      return =>
        animation = new Animation()
        buildTween = =>
          cardSprite = @getFlippedCardSprite()
          tokenSprite = @getTokenSprite()
          cardTween = new TWEEN.Tween({x:cardSprite.position.x, y:cardSprite.position.y, rot:cardSprite.rotation})
          cardTween.to({x:position.x, y:position.y, rot:rotation}, animTime)
          cardTween.easing(TWEEN.Easing.Cubic.Out)
          cardTween.onUpdate ->
            cardSprite.position.x = @x
            cardSprite.position.y = @y
            cardSprite.rotation = @rot
          tweens = [cardTween]
          if tokenSprite?
            tokenTween = new TWEEN.Tween({x:tokenSprite.position.x, y:tokenSprite.position.y, rot:tokenSprite.rotation})
            tokenTween.to({x:position.x, y:position.y, rot:rotation}, animTime)
            tokenTween.easing(TWEEN.Easing.Cubic.Out)
            tokenTween.onUpdate ->
              tokenSprite.position.x = @x
              tokenSprite.position.y = @y
              tokenSprite.rotation = @rot
            tweens.push tokenTween
          return tweens

        animation.addTweenStep buildTween, 'card-move'
        return animation

    moveTokenTo: (position, animTime, disableInteraction, rotation) ->
      rotation = if rotation? then rotation else 0
      return =>
        animation = new Animation()
        animation.addTweenStep =>
          tokenSprite = @tokenSprite
          tokenTween = new TWEEN.Tween({x:tokenSprite.position.x, y:tokenSprite.position.y, rot:tokenSprite.rotation})
          tokenTween.to({x:position.x, y:position.y, rot:rotation}, animTime)
          tokenTween.easing(TWEEN.Easing.Cubic.Out)
          tokenTween.onUpdate ->
            tokenSprite.position.x = @x
            tokenSprite.position.y = @y
            tokenSprite.rotation = @rot
          return tokenTween

        if disableInteraction
          animation.on 'start', =>
            @getAvailableCardSprite().visible = false
          animation.on 'complete', =>
            @updatePopupPosition()
        return animation

    updatePopupPosition: ->
      cardSprite = @getCardSprite()
      cardSprite.position = {x:@tokenSprite.position.x + @tokenSprite.width/2 + @cardSprite.width/2 + POPUP_PADDING, y:@tokenSprite.position.y}
      cardSprite.rotation = 0
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
    setCardRotation: (rotation) ->
      cardSprite = @getAvailableCardSprite()
      cardSprite.rotation = rotation
    setTokenPosition: (position) -> @tokenSprite.position = Util.clone(position)
    setTokenRotation: (rotation) -> @tokenSprite.rotation = rotation
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
    isCardVisible: -> return (@cardSprite? and @cardSprite.visible) or (@flippedCardSprite? and @flippedCardSprite.visible)
    isTokenVisible: -> return @tokenSprite? and @tokenSprite.visible
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
