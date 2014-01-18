define ['gfx/styles', 'util', 'pixi', 'tween'], (STYLES, Util) ->
  ICON_SIZE = 32

  class Icon extends PIXI.DisplayObjectContainer
    constructor: (text, iconTexturePath, textStyle) ->
      super
      @iconSprite = new PIXI.Sprite PIXI.Texture.fromImage(iconTexturePath)
      @iconSprite.width = ICON_SIZE
      @iconSprite.height = ICON_SIZE
      @text = new PIXI.Text text, (textStyle || STYLES.TEXT)
      @text.anchor = {x:0.5, y:0.5}
      @text.position = {x:@iconSprite.width/2, y:@iconSprite.height/2}
      @.addChild @iconSprite
      @.addChild @text
      @width = ICON_SIZE
      @height = ICON_SIZE

    setText:(text) ->
      @text.setText(text)
