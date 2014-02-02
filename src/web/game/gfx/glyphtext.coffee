define ['gfx/styles', 'util', 'pixi', 'tween'], (styles, Util) ->
  STYLE = styles.TEXT
  GLYPHS =
    'coin': '/media/images/icons/coin.png'
    'storypoint': '/media/images/icons/currency_story_points.png'
    'bugsclosed': '/media/images/icons/currency_bugs_closed.png'
    'bugsreported': '/media/images/icons/currency_bugs_reported.png'

  class GlyphText extends PIXI.DisplayObjectContainer
    constructor: (text) ->
      super()
      @setText(text)

    setText: (text) ->
      if @sprites?
        for sprite in @sprites
          @.removeChild sprite
      textChunks = text.split ' '
      @sprites = []
      @width = 0
      for chunk in textChunks
        sprite = null
        if /^<\w+>$/.test(chunk)
          glyph = chunk.replace /[<>]/g, ''
          texture = PIXI.Texture.fromImage GLYPHS[glyph]
          sprite = new PIXI.Sprite texture
          sprite.isGlyph = true
        else
          chunk += ' '
          if @sprites.length > 0 and @sprites[@sprites.length -  1].isGlyph
            chunk = ' ' + chunk
          sprite = new PIXI.Text chunk, STYLE
          sprite.isGlyph = false
        if @sprites.length > 0
          lastSprite = @sprites[@sprites.length - 1]
          sprite.height = lastSprite.height
          @height = sprite.height
          if sprite.isGlyph
            sprite.width = sprite.height
          sprite.position = {x: lastSprite.position.x + lastSprite.width, y:0}
        @sprites.push sprite
      for sprite in @sprites
        @width += sprite.width
        @.addChild sprite
