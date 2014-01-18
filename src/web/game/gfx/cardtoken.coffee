define ['gfx/damageicon', 'gfx/healthicon', 'gfx/styles', 'util', 'pixi', 'tween'], (DamageIcon, HealthIcon, STYLES, Util) ->

  TOKEN_WIDTH = 128
  TOKEN_HEIGHT = 128
  IMAGE_PATH = '/media/images/cards/'
  CLIP_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_clip.png'
  FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_frame.png'
  TAUNT_FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_frame_taunt.png'
  MISSING_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'missing.png'

  ###
  # Represents a card on the field, shown as the card's image with health and damage icons. Minimalized version of the source card.
  ###
  class CardToken extends PIXI.DisplayObjectContainer
    constructor: (card, cardClass) ->
      super
      imageTexture = PIXI.Texture.fromImage IMAGE_PATH + cardClass.media.image
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
      @tauntFrameSprite = new PIXI.Sprite TAUNT_FRAME_TEXTURE
      @tauntFrameSprite.width = TOKEN_WIDTH
      @tauntFrameSprite.height = TOKEN_HEIGHT
      @damageIcon = new DamageIcon card.damage
      @healthIcon = new HealthIcon card.health
      @damageIcon.anchor = {x:0.5, y:0.5}
      @healthIcon.anchor = {x:0.5, y:0.5}
      @damageIcon.position = {x:-@damageIcon.width/2, y:@height - @damageIcon.height/2}
      @healthIcon.position = {x:@width - @healthIcon.width/2, y:@height - @healthIcon.height/2}

      @.addChild @imageSprite
      @.addChild @frameSprite
      @.addChild @tauntFrameSprite
      @.addChild @healthIcon
      @.addChild @damageIcon

      @setTaunt ('taunt' in card.status)

    setHealth: (health) ->
      @healthIcon.setHealth(health)

    setDamage: (damage) ->
      @damageIcon.setDamage(damage)

    setTaunt: (isTaunting) ->
      @tauntFrameSprite.visible = isTaunting
      @frameSprite.visible = !isTaunting

    onHoverStart: (cb) -> @.mouseover = => cb @
    onHoverEnd: (cb) -> @.mouseout = => cb @
    onMouseUp: (cb) -> @.mouseup = => cb @
    onMouseDown: (cb) -> @.mousedown = => cb @

    createImageMask: ->
      mask = new PIXI.Graphics()
      mask.beginFill()
      mask.drawCircle(0, 0, TOKEN_WIDTH/2)
      mask.endFill()
      return mask
