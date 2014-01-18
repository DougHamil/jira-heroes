define ['gfx/styles', 'util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  BUTTON_WIDTH = 128
  BUTTON_HEIGHT = 32
  class EndTurnButton extends PIXI.DisplayObjectContainer
    constructor: ->
      super
      # TODO: Dress this up
      @width = BUTTON_WIDTH
      @height = BUTTON_HEIGHT
      @bg = new PIXI.Graphics()
      @bg.width = @width
      @bg.height = @height
      @bg.beginFill STYLES.BUTTON_COLOR
      @bg.drawRect 0, 0, @bg.width, @bg.height
      @bg.endFill()
      @text = new PIXI.Text 'End Turn', STYLES.TEXT
      @text.position = {x:@bg.width/2 - @text.width/2, y:@bg.height/2 - @text.height/2}

      @.addChild @bg
      @.addChild @text

      @.hitArea = new PIXI.Rectangle 0, 0, @width, @height
      @.interactive = true

    onClick: (callback) -> @.click = => callback(@) if callback?
