define ['gfx/styles', 'util', 'pixi', 'tween'], (styles, Util) ->
  STYLE = styles.TEXT
  GLYPHS =
    'coin': '/media/images/icons/coin.png'
    'storypoint': '/media/images/icons/currency_story_points.png'
    'bugsclosed': '/media/images/icons/currency_bugs_closed.png'
    'bugsreported': '/media/images/icons/currency_bugs_reported.png'
    'alert':'/media/images/icons/alert.png'

  class GlyphText extends PIXI.DisplayObjectContainer
    constructor: (text, style, tint, size, @center) ->
      super()
      @container = new PIXI.DisplayObjectContainer()
      @container.anchor = {x:0.5, y:0.5}
      @.addChild @container
      @setText(text, style, tint, size)

    setText: (text, style, tint, size) ->
      style = STYLE if not style?
      if @sprites?
        for sprite in @sprites
          @container.removeChild sprite
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
          if size?
            sprite.width = size
            sprite.height = size
          if tint?
            sprite.tint = tint
        else
          chunk += ' '
          if @sprites.length > 0 and @sprites[@sprites.length -  1].isGlyph
            chunk = ' ' + chunk
          sprite = new PIXI.Text chunk, style
          sprite.isGlyph = false
        if @sprites.length > 0
          lastSprite = @sprites[@sprites.length - 1]
          if not size?
            sprite.height = lastSprite.height
          @height = sprite.height
          if sprite.isGlyph
            sprite.width = sprite.height
          sprite.position = {x: lastSprite.position.x + lastSprite.width, y:0}
        @sprites.push sprite
      for sprite in @sprites
        @width += sprite.width
        @container.addChild sprite
      if @center
        @container.position = {x:-@width/2, y:0}
