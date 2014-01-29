define ['gfx/damageicon', 'gfx/healthicon', 'gfx/styles', 'util', 'pixi', 'tween'], (DamageIcon, HealthIcon, STYLES, Util) ->
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
      console.log heroClass
      imageTexture = PIXI.Texture.fromImage IMAGE_PATH + heroClass.media.image
      @width = TOKEN_WIDTH
      @height = TOKEN_HEIGHT
      @imageSprite = new PIXI.Sprite imageTexture
      @imageSprite.width = TOKEN_WIDTH
      @imageSprite.height = TOKEN_HEIGHT
      @imageSprite.mask = @createImageMask()
      @frameSprite = new PIXI.Sprite FRAME_TEXTURE
      @frameSprite.width = TOKEN_WIDTH
      @frameSprite.height = TOKEN_HEIGHT
      @damageIcon = new DamageIcon hero.damage
      @healthIcon = new HealthIcon hero.health
      @damageIcon.anchor = {x:0, y:0}
      @healthIcon.anchor = {x:0, y:0}
      @damageIcon.position = {x:0, y:@height - @damageIcon.height}
      @healthIcon.position = {x:@width - @healthIcon.width, y:@height - @healthIcon.height}

      @.addChild @imageSprite
      @.addChild @imageSprite.mask
      @.addChild @frameSprite
      @.addChild @healthIcon
      @.addChild @damageIcon

      @hitArea = new PIXI.Rectangle 0, 0, @width, @height

    setHealth: (health) ->
      @healthIcon.setHealth(health)

    setDamage: (damage) ->
      @damageIcon.setDamage(damage)

    contains: (point) ->
      point = {x:point.x - @position.x, y:point.y - @position.y}
      return @visible and @hitArea.contains(point.x, point.y)

    getCenterPosition: ->
      return {x:@.position.x + @width/2, y:@.position.y + @height/2}

    createImageMask: ->
      mask = new PIXI.Graphics()
      mask.beginFill()
      mask.drawRect(0,0,TOKEN_WIDTH, TOKEN_HEIGHT)
      mask.endFill()
      return mask
