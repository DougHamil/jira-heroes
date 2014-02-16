define ['gfx/styles', 'util', 'pixi', 'tween'], (styles, Util) ->
  PADDING = 0
  class SpriteButton extends PIXI.DisplayObjectContainer
    constructor: (texture, size) ->
      super
      @sprite = new PIXI.Sprite texture
      if size?
        @width = size.width
        @height = size.height
        @sprite.width = size.width
        @sprite.height = size.height
      else
        @width = @sprite.width + PADDING
        @height = @sprite.height + PADDING
      @.addChild @sprite
      @enabled = true
      @.hitArea = new PIXI.Rectangle(0, 0, @width, @height)
      @.buttonMode = true
      @.interactive = true

    disable: ->
      @enabled = false
    enable: ->
      @enabled = true

    onClick: (callback) ->
      @.click = =>
        if @enabled
          callback(@)
