define ['gfx/styles', 'util', 'pixi', 'tween'], (styles, Util) ->
  PADDING = 0
  class SpriteButton extends PIXI.DisplayObjectContainer
    constructor: (texture) ->
      super
      @sprite = new PIXI.Sprite texture
      @width = @sprite.width + PADDING
      @height = @sprite.height + PADDING
      @.addChild @sprite
      @enabled = true
      @.hitArea = new PIXI.Rectangle(0, 0, @width, @height)
      @.interactive = true

    disable: ->
      @enabled = false
    enable: ->
      @enabled = true

    onClick: (callback) ->
      @.click = =>
        if @enabled
          callback(@)
