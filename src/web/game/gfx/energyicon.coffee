define ['gfx/styles', 'util', 'pixi', 'tween'], (STYLES, Util) ->
  ICON_SIZE = 32
  ICON_TEXTURE = PIXI.Texture.fromImage '/media/images/icons/energy.png'

  class EnergyIcon extends PIXI.DisplayObjectContainer
    constructor: (energy) ->
      super
      @iconSprite = new PIXI.Sprite ICON_TEXTURE
      @iconSprite.width = ICON_SIZE
      @iconSprite.height = ICON_SIZE
      @text = new PIXI.Text energy.toString(), GUI.STYLES.TEXT
      @text.anchor = {x:0.5, y:0.5}
      @.addChild @iconSprite
      @.addChild @text
      @width = ICON_SIZE
      @height = ICON_SIZE

    setEnergy:(energy) ->
      @text.setText(energy)
