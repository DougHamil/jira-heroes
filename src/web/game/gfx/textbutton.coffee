define ['gfx/styles', 'util', 'pixi', 'tween'], (styles, Util) ->
  PADDING = 20
  class TextButton extends PIXI.DisplayObjectContainer
    constructor: (text) ->
      super
      @text = new PIXI.Text text, styles.TEXT
      @bg = new PIXI.Graphics()
      @width = @text.width + PADDING
      @height = @text.height + PADDING
      @bg.beginFill styles.BUTTON_COLOR
      @bg.drawRect 0, 0, @width, @height
      @disableBg = new PIXI.Graphics()
      @disableBg.beginFill styles.BUTTON_COLOR_DISABLED
      @disableBg.drawRect 0, 0, @width, @height
      @text.anchor = {x:0.5, y:0.5}
      @bg.anchor = {x:0.5, y:0.5}
      @text.position = {x:(@width)/2, y:(@height)/2 }
      @disableBg.anchor = {x:0.5, y:0.5}
      @.addChild @disableBg
      @.addChild @bg
      @.addChild @text
      @enabled = true
      @.hitArea = new PIXI.Rectangle(0, 0, @width, @height)
      @.interactive = true

    disable: ->
      @bg.visible = false
      @enabled = false
    enable: ->
      @bg.visible = true
      @enabled = true

    onClick: (callback) ->
      @.click = =>
        if @enabled
          callback(@)
