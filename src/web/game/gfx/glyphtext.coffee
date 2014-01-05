define ['gfx/styles', 'util', 'pixi', 'tween'], (styles, Util) ->
  STYLE = styles.TEXT
  GLYPHS =
    'coin': '/media/images/icons/coin.png'

  class GlyphText extends PIXI.DisplayObjectContainer
    constructor: (text) ->
      super()
      textChunks = text.split ' '
      sprites = []
      @width = 0
      for chunk in textChunks
        sprite = null
        if /^<\w+>$/.test(chunk)
          glyph = chunk.replace /[<>]/g, ''
          texture = PIXI.Texture.fromImage GLYPHS[glyph]
          sprite = new PIXI.Sprite texture
        else
          chunk += ' '
          sprite = new PIXI.Text chunk, STYLE
        if sprites.length > 0
          lastSprite = sprites[sprites.length - 1]
          sprite.height = lastSprite.height
          @height = sprite.height
          sprite.width = sprite.height
          sprite.position = {x: lastSprite.position.x + lastSprite.width, y:0}
        sprites.push sprite

      for sprite in sprites
        @width += sprite.width
        @.addChild sprite

