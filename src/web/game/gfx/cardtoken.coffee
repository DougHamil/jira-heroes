define ['gfx/damageicon', 'gfx/healthicon', 'gfx/styles', 'util', 'pixi', 'tween'], (DamageIcon, HealthIcon, STYLES, Util) ->
  TOKEN_WIDTH = 128
  TOKEN_HEIGHT = 128
  IMAGE_PATH = '/media/images/cards/'
  FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_frame.png'
  TAUNT_FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_frame_taunt.png'
  FROZEN_FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_frame_frozen.png'
  SLEEPING_OVERLAY_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_overlay_sleeping.png'
  MISSING_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'missing.png'

  ###
  # Represents a card on the field, shown as the card's image with health and damage icons. Minimalized version of the source card.
  ###
  class CardToken extends PIXI.DisplayObjectContainer
    @Width: TOKEN_WIDTH
    @Height: TOKEN_HEIGHT
    constructor: (card, cardClass) ->
      super
      imageTexture = PIXI.Texture.fromImage IMAGE_PATH + cardClass.media.image
      @width = TOKEN_WIDTH
      @height = TOKEN_HEIGHT
      @sleepingSprite = new PIXI.Sprite SLEEPING_OVERLAY_TEXTURE
      @sleepingSprite.width = TOKEN_WIDTH
      @sleepingSprite.height = TOKEN_HEIGHT
      @frozenSprite = new PIXI.Sprite FROZEN_FRAME_TEXTURE
      @frozenSprite.width = TOKEN_WIDTH
      @frozenSprite.height = TOKEN_HEIGHT
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
      @damageIcon.position = {x:0, y:@height - @damageIcon.height}
      @healthIcon.position = {x:@width - @healthIcon.width, y:@height - @healthIcon.height}

      @.addChild @frameSprite
      @.addChild @tauntFrameSprite
      @.addChild @imageSprite.mask
      @.addChild @imageSprite
      @.addChild @frozenSprite
      @.addChild @sleepingSprite
      @.addChild @healthIcon
      @.addChild @damageIcon

      @.hitArea = new PIXI.Rectangle 0, 0, @width, @height
      @.interactive = true

      @setTaunt ('taunt' in card.getStatus())
      @setFrozen ('frozen' in card.getStatus())
      @setSleeping ('sleeping' in card.getStatus())

    contains: (point) ->
      point = {x:point.x - @position.x, y:point.y - @position.y}
      return @visible and @hitArea.contains(point.x, point.y)

    setHealth: (health) ->
      @healthIcon.setHealth(health)

    setDamage: (damage) ->
      @damageIcon.setDamage(damage)

    setTaunt: (isTaunting) ->
      @tauntFrameSprite.visible = isTaunting
      @frameSprite.visible = !isTaunting
    setFrozen: (isFrozen) -> @frozenSprite.visible = isFrozen
    setSleeping: (isSleeping) -> @sleepingSprite.visible = isSleeping

    getCenterPosition: ->
      return {x:@.position.x + @width/2, y:@.position.y + @height/2}

    onHoverStart: (cb) -> @.mouseover = => cb @
    onHoverEnd: (cb) -> @.mouseout = => cb @
    onMouseUp: (cb) -> @.mouseup = => cb @
    onMouseDown: (cb) -> @.mousedown = => cb @

    removeAllInteractions: ->
      @.mouseover = null
      @.mouseout = null
      @.click = null
      @.mousedown = null
      @.mouseup = null

    createImageMask: ->
      mask = new PIXI.Graphics()
      mask.beginFill()
      mask.drawCircle(TOKEN_WIDTH/2, TOKEN_HEIGHT/2, TOKEN_WIDTH/2-5)
      mask.endFill()
      return mask
