define ['eventemitter', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (EventEmitter, Animation, GUI, engine, Util) ->
  class BattleHero extends EventEmitter
    constructor: (@hero, @heroClass, @interactive) ->
      super
      @token = new GUI.HeroToken @hero, @heroClass
      @damageIndicator = new GUI.DamageIndicator 0
      @damageIndicator.visible = false
      @damageIndicator.position = {x:@token.width/2, y:@token.height/2}
      @token.addChild @damageIndicator

    animateDamaged:(amount)->
      animation = new Animation()
      animation.addUnchainedAnimationStep @damageIndicator.animate(amount)
      animation.on 'complete', => @getTokenSprite().setHealth(@hero.health)
      return animation

    animateAction: (action) ->
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
          return @animationStatusRemove(action.status)
        when 'add-modifier'
          return @animateModifierAdd(action.modifier)
        when 'remove-modifier'
          return @animateModifierRemove(action.modifier)
      console.log Error("BattleHero cannot animate #{action.type}!")

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
