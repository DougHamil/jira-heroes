define ['emitters','eventemitter', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (Emitters, EventEmitter, Animation, GUI, engine, Util) ->
  HEAL_TEXTURE = PIXI.Texture.fromImage '/media/images/fx/cross.png'
  class BattleHero extends EventEmitter
    constructor: (@hero, @heroClass, @interactive, @uiLayer) ->
      super
      @token = new GUI.HeroToken @hero, @heroClass
      @abilityToken = new GUI.HeroAbilityToken @hero, @heroClass.ability, @heroClass
      @damageIndicator = new GUI.DamageIndicator 0
      @damageIndicator.visible = false
      @isAbilityTargeting = false
      @isTargeting = false
      @token.addChild @damageIndicator
      if @interactive
        @token.mousedown = =>
          if @hero.getDamage() > 0
            @isTargeting = true
        if @heroClass.ability.requiresTarget
          @abilityToken.mousedown = =>
            @isAbilityTargeting = true
        else
          @abilityToken.click = => @emit 'hero-cast-ability', @

    animateAction: (action) ->
      action.animated = true
      switch action.type
        when 'weapon-equip'
          return @animateWeaponEquip(action.weapon)
        when 'weapon-destroy'
          return @animateWeaponDestroy()
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
      console.log Error("BattleHero cannot animate #{action.type}!")

    animateAbilityCasted:()->
      #TODO: Fancy ability cast animation
      animation = new Animation()
      return animation

    animateDamaged:(amount)->
      animation = new Animation()
      animation.addUnchainedAnimationStep @damageIndicator.animate(amount)
      health = if amount then @getTokenSprite().getHealth() - amount else @hero.health
      if health < @hero.health
        health = @hero.health
      animation.on 'complete', => @getTokenSprite().setHealth(health)
      return animation

    animateWeaponEquip: (weapon) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setDamage(@hero.getDamage())
        @getTokenSprite().setWeaponDurability(@hero.getWeaponDurability())
      return animation

    animateWeaponDestroy: () ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setDamage(@hero.getDamage())
        @getTokenSprite().setWeaponDurability(@hero.getWeaponDurability())
      return animation

    animateModifierAdd: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setFrozen('frozen' in @hero.getStatus())
        @getTokenSprite().setDamage(@hero.getDamage())
      return animation

    animateModifierRemove: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setFrozen('frozen' in @hero.getStatus())
        @getTokenSprite().setDamage(@hero.getDamage())
      return animation

    animateStatusAdd: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setFrozen('frozen' in @hero.getStatus())
        @getTokenSprite().setUsed('used' in @hero.getStatus())
        @getAbilityTokenSprite().setUsed('ability-used' in @hero.getStatus())
      return animation

    animateStatusRemove: (status) ->
      #TODO: Fancy status-specific animations
      animation = new Animation()
      animation.on 'complete', =>
        @getTokenSprite().setFrozen('frozen' in @hero.getStatus())
        @getTokenSprite().setUsed('used' in @hero.getStatus())
        @getAbilityTokenSprite().setUsed('ability-used' in @hero.getStatus())
      return animation

    animateOverhealed: (amount)->
      animation = new Animation()
      health = if amount then @getTokenSprite().getHealth() + amount else @hero.health
      if health > @hero.health
        health = @hero.health
      animation.on 'start', =>
        emitter = Emitters.SpriteRing {texture:HEAL_TEXTURE,tint:0x22B222,life:[0.5,1]}
        emitter.p.x = @getTokenSprite().position.x
        emitter.p.y = @getTokenSprite().position.y
        emitter.emit 'once'
      animation.on 'complete', => @getTokenSprite().setHealth(health)
      return animation

    animateHealed: (amount)->
      animation = new Animation()
      health = if amount then @getTokenSprite().getHealth() + amount else @hero.health
      if health > @hero.health
        health = @hero.health
      animation.on 'start', =>
        emitter = Emitters.SpriteRing {texture:HEAL_TEXTURE, life:[0.5,1], tint:0x22B222}
        emitter.p.x = @getTokenSprite().position.x
        emitter.p.y = @getTokenSprite().position.y
        emitter.emit('once')

      animation.on 'complete', => @getTokenSprite().setHealth(health)
      return animation

    animateDestroyed: ->
      animation = new Animation()
      sprite = @getTokenSprite()
      animation.addTweenStep Util.fadeSpriteTween(sprite, 0, 500)
      animation.on 'complete', => @getTokenSprite().visible = false
      return animation

    onMouseUp: (pos)->
      if @isTargeting
        @emit 'hero-target', @, pos
      else if @isAbilityTargeting
        @emit 'hero-ability-target', @, pos
      if @targetGfx?
        @uiLayer.removeChild @targetGfx
        @targetGfx = null
      @isTargeting = false
      @isAbilityTargeting = false

    update: ->
      if not @isTargeting and not @isAbilityTargeting
        return
      sourceToken = if @isTargeting then @token.getCenterPosition() else @abilityToken.getCenterPosition()
      mousePos = @token.stage.getMousePosition().clone()
      if @targetGfx?
        @uiLayer.removeChild @targetGfx
      @targetGfx = Util.drawArrow(sourceToken, mousePos)
      @uiLayer.addChild @targetGfx

    containsPoint: (point) -> return @token.contains(point)
    getId: -> return @hero.userId
    getTokenSprite: -> return @token
    getAbilityTokenSprite: -> return @abilityToken
