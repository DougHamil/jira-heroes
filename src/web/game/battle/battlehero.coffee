define ['eventemitter', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (EventEmitter, Animation, GUI, engine, Util) ->
  class BattleHero extends EventEmitter
    constructor: (@hero, @heroClass, @interactive) ->
      super
      @token = new GUI.HeroToken @hero, @heroClass

    animateDamaged:->
      animation = new Animation()
      jitterSteps = 5
      sprite = @getTokenSprite()
      for i in [0...5]
        animation.addTweenStep ->
          return Util.spriteTween sprite, sprite.position, Util.pointJitter(sprite.position, 10), 100
      return animation

    animateModifierAdd: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        console.log @hero.getStatus()
        @getTokenSprite().setFrozen('frozen' in @hero.getStatus())
        @getTokenSprite().setTaunt('taunt' in @hero.getStatus())
        @getTokenSprite().setSleeping('sleeping' in @hero.getStatus())
        @getTokenSprite().setDamage(@hero.getDamage())
      return animation

    animateModifierRemove: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setFrozen('frozen' in @hero.getStatus())
        @getTokenSprite().setTaunt('taunt' in @hero.getStatus())
        @getTokenSprite().setSleeping('sleeping' in @hero.getStatus())
        @getTokenSprite().setDamage(@hero.getDamage())
      return animation

    animateStatusAdd: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        console.log @hero.getStatus()
        @getTokenSprite().setFrozen('frozen' in @hero.getStatus())
        @getTokenSprite().setTaunt('taunt' in @hero.getStatus())
        @getTokenSprite().setSleeping('sleeping' in @hero.getStatus())
        @getTokenSprite().setUsed('used' in @hero.getStatus())
      return animation

    animateStatusRemove: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setFrozen('frozen' in @hero.getStatus())
        @getTokenSprite().setTaunt('taunt' in @hero.getStatus())
        @getTokenSprite().setSleeping('sleeping' in @hero.getStatus())
        @getTokenSprite().setUsed('used' in @hero.getStatus())
      return animation

    animateHealed: ->
      animation = new Animation()
      animation.on 'complete', => @getTokenSprite().setHealth(@hero.health)
      return animation

    animateDestroyed: ->
      animation = new Animation()
      sprite = @getTokenSprite()
      animation.addTweenStep Util.fadeSpriteTween(sprite, 0, 500)
      animation.on 'complete', => @getTokenSprite().visible = false
      return animation

    containsPoint: (point) -> return @token.contains(point)
    getId: -> return @hero.userId
    getTokenSprite: -> return @token
