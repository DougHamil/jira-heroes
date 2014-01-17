define ['gfx/styles', 'util', 'pixi', 'tween'], (STYLES, Util) ->
  ICON_SIZE = 32
  ICON_TEXTURE = PIXI.Texture.fromImage '/media/images/icons/health.png'

  class HealthIcon extends PIXI.DisplayObjectContainer
    constructor: (health) ->
      super
      @iconSprite = new PIXI.Sprite ICON_TEXTURE
      @iconSprite.width = ICON_SIZE
      @iconSprite.height = ICON_SIZE
      @text = new PIXI.Text health.toString(), GUI.STYLES.TEXT
      @text.anchor = {x:0.5, y:0.5}
      @.addChild @iconSprite
      @.addChild @text
      @width = ICON_SIZE
      @height = ICON_SIZE

    setHealth:(health) ->
      @text.setText(health)
