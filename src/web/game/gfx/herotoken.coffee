define ['gfx/duraicon', 'gfx/damageicon', 'gfx/healthicon', 'gfx/styles', 'util', 'pixi', 'tween'], (DuraIcon, DamageIcon, HealthIcon, STYLES, Util) ->
  FROZEN_TINT = 0xFF0000
  DEFAULT_TINT = 0x77DDEE
  USED_TINT = 0xBBBBBB

  TOKEN_WIDTH = 128
  TOKEN_HEIGHT = 128
  IMAGE_PATH = '/media/images/heroes/'
  FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_frame.png'
  MISSING_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'missing.png'

  ###
  # Represent's the player's hero in-game. Shows the hero's current damage and health
  ###
  class HeroToken extends PIXI.DisplayObjectContainer
    @Width: TOKEN_WIDTH
    @Height: TOKEN_HEIGHT
    constructor: (hero, heroClass) ->
      super
      imageTexture = PIXI.Texture.fromImage IMAGE_PATH + heroClass.media.image
      @width = TOKEN_WIDTH
      @height = TOKEN_HEIGHT
      @frozenSprite = new PIXI.Text "FROZEN", STYLES.DAMAGE_TEXT
      @frozenSprite.anchor = {x:0.5, y:0.5}
      @frozenSprite.visible = false
      @usedSprite = new PIXI.Text "USED", STYLES.DAMAGE_TEXT
      @usedSprite.anchor = {x:0.5, y:0.5}
      @usedSprite.visible = false
      @imageSprite = new PIXI.Sprite imageTexture
      @imageSprite.width = TOKEN_WIDTH
      @imageSprite.height = TOKEN_HEIGHT
      @imageSprite.position = {x:-@imageSprite.width/2, y:-@imageSprite.height/2}
      @imageSprite.mask = @createImageMask()
      @frameSprite = new PIXI.Sprite FRAME_TEXTURE
      @frameSprite.width = TOKEN_WIDTH
      @frameSprite.height = TOKEN_HEIGHT
      @frameSprite.position = {x:-@frameSprite.width/2, y:-@frameSprite.height/2}
      @damageIcon = new DamageIcon hero.getDamage(), heroClass.damage
      @healthIcon = new HealthIcon hero.health, heroClass.health
      @duraIcon = new DuraIcon hero.getWeaponDurability(),  0
      @damageIcon.position = {x:-@width/2, y:@height/2 - @damageIcon.height}
      @duraIcon.position = {x:-@width/2, y:@height/2 - @damageIcon.height - @duraIcon.height}
      @healthIcon.position = {x:@width/2 - @healthIcon.width, y:@height/2 - @healthIcon.height}

      @.addChild @imageSprite
      @.addChild @imageSprite.mask
      @.addChild @frameSprite
      @.addChild @frozenSprite
      @.addChild @usedSprite
      @.addChild @healthIcon
      @.addChild @damageIcon
      @.addChild @duraIcon

      @hitArea = new PIXI.Rectangle -@width/2, -@height/2, @width, @height
      @interactive = true

      @setHealth(hero.health)
      @setDamage(hero.getDamage())
      @setWeaponDurability(hero.getWeaponDurability())
      @setUsed ('used' in hero.getStatus())
      @setFrozen ('frozen' in hero.getStatus())

    getHealth: -> return @healthIcon.health
    setHealth: (health) ->
      @healthIcon.setHealth(health)

    getDamage: -> return @damageIcon.damage
    setDamage: (damage) ->
      @damageIcon.setDamage(damage)
      @damageIcon.visible = damage isnt 0

    setWeaponDurability:(dura) ->
      @duraIcon.setDurability(dura)
      @duraIcon.visible = dura isnt 0

    setFrozen: (isFrozen) ->
      @frameSprite.tint = if isFrozen then FROZEN_TINT else DEFAULT_TINT

    setUsed: (isUsed) ->
      if isUsed
        @frameSprite.tint = USED_TINT
      else
        @frameSprite.tint = DEFAULT_TINT

    contains: (point) ->
      point = {x:point.x - @position.x, y:point.y - @position.y}
      return @visible and @hitArea.contains(point.x, point.y)

    getCenterPosition: -> return {x:@position.x, y:@position.y}

    createImageMask: ->
      mask = new PIXI.Graphics()
      mask.beginFill()
      mask.drawRect(-TOKEN_WIDTH/2,-TOKEN_HEIGHT/2,TOKEN_WIDTH, TOKEN_HEIGHT)
      mask.endFill()
      return mask
