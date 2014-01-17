define ['gfx/damageicon', 'gfx/healthicon', 'gfx/styles', 'util', 'pixi', 'tween'], (DamageIcon, HealthIcon, STYLES, Util) ->

  TOKEN_WIDTH = 128
  TOKEN_HEIGHT = 128
  IMAGE_PATH = '/media/images/heroes/'
  CLIP_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_clip.png'
  FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_frame.png'
  MISSING_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'missing.png'

  ###
  # Represent's the player's hero in-game. Shows the hero's current damage and health
  ###
  class HeroToken extends PIXI.DisplayObjectContainer
    constructor: (hero, heroClass) ->
      super
      imageTexture = PIXI.Texture.fromImage IMAGE_PATH + heroClass.media.image
      if not imageTexture.hasLoaded
        imageTexture = MISSING_TEXTURE
      @width = TOKEN_WIDTH
      @height = TOKEN_HEIGHT
      @imageSprite = new PIXI.Sprite imageTexture
      @imageSprite.width = TOKEN_WIDTH
      @imageSprite.height = TOKEN_HEIGHT
      @imageSprite.mask = @createImageMask()
      @frameSprite = new PIXI.Sprite FRAME_TEXTURE
      @frameSprite.width = TOKEN_WIDTH
      @frameSprite.height = TOKEN_HEIGHT
      @damageIcon = new DamageIcon card.damage
      @healthIcon = new HealthIcon card.health
      @damageIcon.anchor = {x:0.5, y:0.5}
      @healthIcon.anchor = {x:0.5, y:0.5}
      @damageIcon.position = {x:-@damageIcon.width/2, y:@height - @damageIcon.height/2}
      @healthIcon.position = {x:-@healthIcon.width/2, y:@height - @healthIcon.height/2}

      @.addChild @imageSprite
      @.addChild @frameSprite
      @.addChild @healthIcon
      @.addChild @damageIcon

    setHealth: (health) ->
      @healthIcon.setHealth(health)

    setDamage: (damage) ->
      @damageIcon.setDamage(damage)

    createImageMask: ->
      mask = new PIXI.Graphics()
      mask.beginFill()
      mask.drawCircle(0, 0, TOKEN_WIDTH)
      mask.endFill()
      return mask
