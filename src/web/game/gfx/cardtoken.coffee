define ['gfx/damageicon', 'gfx/healthicon', 'gfx/styles', 'util', 'pixi', 'tween'], (DamageIcon, HealthIcon, STYLES, Util) ->
  FROZEN_TINT = 0xFF0000
  DEFAULT_TINT = 0x77DDEE

  TOKEN_WIDTH = 128
  TOKEN_HEIGHT = 128
  IMAGE_PATH = '/media/images/cards/'
  FRAME_HIGHLIGHT_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_highlight.png'
  FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token.png'
  TAUNT_FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_taunt.png'
  TAUNT_FRAME_HIGHLIGHT_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'token_taunt_highlight.png'
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
      @imageSprite = new PIXI.Sprite imageTexture
      @imageSprite.width = TOKEN_WIDTH
      @imageSprite.height = TOKEN_HEIGHT
      @imageSprite.mask = @createImageMask()
      @frameHighlightSprite = new PIXI.Sprite FRAME_HIGHLIGHT_TEXTURE
      @frameHighlightSprite.width = TOKEN_WIDTH
      @frameHighlightSprite.height = TOKEN_HEIGHT
      @frameHighlightSprite.visible = false
      @frameSprite = new PIXI.Sprite FRAME_TEXTURE
      @frameSprite.width = TOKEN_WIDTH
      @frameSprite.height = TOKEN_HEIGHT
      @tauntFrameSprite = new PIXI.Sprite TAUNT_FRAME_TEXTURE
      @tauntFrameSprite.width = TOKEN_WIDTH
      @tauntFrameSprite.height = TOKEN_HEIGHT
      @tauntFrameSprite.visible = false
      @tauntHighlightSprite = new PIXI.Sprite TAUNT_FRAME_HIGHLIGHT_TEXTURE
      @tauntHighlightSprite.width = TOKEN_WIDTH
      @tauntHighlightSprite.height = TOKEN_HEIGHT
      @tauntHighlightSprite.visible = false
      @damageIcon = new DamageIcon card.getDamage(), cardClass.damage
      @healthIcon = new HealthIcon card.health, cardClass.health
      @damageIcon.anchor = {x:0.5, y:0.5}
      @healthIcon.anchor = {x:0.5, y:0.5}
      @damageIcon.position = {x:0, y:@height - @damageIcon.height}
      @healthIcon.position = {x:@width - @healthIcon.width, y:@height - @healthIcon.height}

      @.addChild @imageSprite.mask
      @.addChild @imageSprite
      @.addChild @frameSprite
      @.addChild @frameHighlightSprite
      @.addChild @tauntFrameSprite
      @.addChild @tauntHighlightSprite
      @.addChild @sleepingSprite
      @.addChild @healthIcon
      @.addChild @damageIcon

      @.hitArea = new PIXI.Rectangle 0, 0, @width, @height
      @.interactive = true

      @setTaunt ('taunt' in card.getStatus())
      @setFrozen ('frozen' in card.getStatus())
      @setSleeping ('sleeping' in card.getStatus())
      @setUsed ('used' in card.getStatus())

    contains: (point) ->
      point = {x:point.x - @position.x, y:point.y - @position.y}
      return @visible and @hitArea.contains(point.x, point.y)

    setUsed:(isUsed) ->
      if @frameSprite.visible or @frameHighlightSprite.visible
        @frameSprite.visible = isUsed
        @frameHighlightSprite.visible = !isUsed
      else
        @tauntFrameSprite.visible = isUsed
        @tauntHighlightSprite.visible = !isUsed

    setHealth: (health) ->
      @healthIcon.setHealth(health)

    setDamage: (damage) ->
      @damageIcon.setDamage(damage)

    setTaunt: (isTaunting) ->
      if @frameSprite.visible or @tauntFrameSprite.visible
        @tauntFrameSprite.visible = isTaunting
        @frameSprite.visible = !isTaunting
      else
        @frameHighlightSprite.visible = !isTaunting
        @tauntHighlightSprite.visible = isTaunting

    setFrozen: (isFrozen) ->
      tint = if isFrozen then FROZEN_TINT else DEFAULT_TINT
      @frameSprite.tint = tint
      @tauntFrameSprite.tint = tint
      @frameHighlightSprite.tint = tint
      @tauntHighlightSprite.tint = tint

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
      mask.drawCircle(TOKEN_WIDTH/2, TOKEN_HEIGHT/2, TOKEN_WIDTH/2-10)
      mask.endFill()
      return mask
