define ['gfx/heroabilitypopup','gfx/energyicon','gfx/styles', 'util', 'pixi', 'tween'], (HeroAbilityPopup, EnergyIcon, STYLES, Util) ->
  TOKEN_WIDTH = 128
  TOKEN_HEIGHT = 128
  IMAGE_PATH = '/media/images/heroes/'
  FRAME_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'ability_token.png'
  FRAME_HIGHLIGHT_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'ability_token_highlight.png'

  ###
  # Represents a card on the field, shown as the card's image with health and damage icons. Minimalized version of the source card.
  ###
  class HeroAbilityToken extends PIXI.DisplayObjectContainer
    @Width: TOKEN_WIDTH
    @Height: TOKEN_HEIGHT
    constructor: (hero, heroAbility, heroClass) ->
      super
      @popup = new HeroAbilityPopup heroClass, heroAbility
      imageTexture = PIXI.Texture.fromImage IMAGE_PATH + heroAbility.media.image
      @width = TOKEN_WIDTH
      @height = TOKEN_HEIGHT
      @imageSprite = new PIXI.Sprite imageTexture
      @imageSprite.width = TOKEN_WIDTH
      @imageSprite.height = TOKEN_HEIGHT
      @imageSprite.mask = @createImageMask()
      @frameSprite = new PIXI.Sprite FRAME_TEXTURE
      @frameSprite.width = TOKEN_WIDTH
      @frameSprite.height = TOKEN_HEIGHT
      @frameHighlightSprite = new PIXI.Sprite FRAME_HIGHLIGHT_TEXTURE
      @frameHighlightSprite.width = TOKEN_WIDTH
      @frameHighlightSprite.height = TOKEN_HEIGHT
      @energyIcon = new EnergyIcon hero.getAbilityEnergy(), heroAbility.abilityEnergy
      @energyIcon.anchor = {x:0.5, y:0.5}
      @energyIcon.position = {x:@width - @energyIcon.width, y:0}

      @popup.position = {x: -20 - @popup.width, y:0}
      @popup.visible = false

      @.addChild @imageSprite.mask
      @.addChild @imageSprite
      @.addChild @frameSprite
      @.addChild @frameHighlightSprite
      @.addChild @energyIcon
      @.hitArea = new PIXI.Rectangle 0, 0, @width, @height
      @.interactive = true

      @setUsed ('ability-used' in hero.getStatus())

      @.mouseover = => @popup.visible = true
      @.mouseout = => @popup.visible = false

    contains: (point) ->
      point = {x:point.x - @position.x, y:point.y - @position.y}
      return @visible and @hitArea.contains(point.x, point.y)

    setUsed:(isUsed) ->
      @frameSprite.visible = isUsed
      @frameHighlightSprite.visible = !isUsed

    getPopupSprite: -> return @popup
    setEnergy: (energy) -> @energyIcon.setEnergy(energy)

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
