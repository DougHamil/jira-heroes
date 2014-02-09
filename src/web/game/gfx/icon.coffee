define ['gfx/styles', 'util', 'pixi', 'tween'], (STYLES, Util) ->
  TWEEN_TIME = 400
  ICON_WIDTH = 64
  ICON_HEIGHT = 32

  class Icon extends PIXI.DisplayObjectContainer
    constructor: (text, iconTexturePath, textStyle) ->
      super
      @iconSprite = new PIXI.Sprite PIXI.Texture.fromImage(iconTexturePath)
      @iconSprite.width = ICON_WIDTH
      @iconSprite.height = ICON_HEIGHT
      @text = new PIXI.Text text, (textStyle || STYLES.TEXT)
      @text.anchor = {x:0.5, y:0.5}
      @text.position = {x:@iconSprite.width/4, y:@iconSprite.height/2}
      @.addChild @iconSprite
      @.addChild @text
      @width = ICON_WIDTH
      @height = ICON_HEIGHT

    setText:(text) ->
      if @iconTween?
        @iconTween.stop()
      textSprite = @text
      tween = new TWEEN.Tween({s:@text.scale.x}).to({s:1.2}, TWEEN_TIME).easing(TWEEN.Easing.Elastic.Out).onUpdate ->
        textSprite.scale.x = @s
        textSprite.scale.y = @s
      @text.setText(text)
      tween.yoyo(true)
      tween.start()

    setStyle:(style) -> @text.setStyle style
