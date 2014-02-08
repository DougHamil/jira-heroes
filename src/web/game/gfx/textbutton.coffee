define ['gfx/styles', 'util', 'pixi', 'tween'], (styles, Util) ->
  PADDING = 20
  LINE_COLOR = 0x3399BB
  LINE_HEIGHT = 2
  UNDERLINE_PADDING = 10
  LINE_GROW_TIME = 200
  class TextButton extends PIXI.DisplayObjectContainer
    constructor: (text) ->
      super
      @text = new PIXI.Text text, styles.TEXT
      lineWidth = @text.width / 2
      @lineScale = (@text.width + PADDING) / lineWidth
      @line = new PIXI.Graphics()
      @line.lineStyle LINE_HEIGHT, LINE_COLOR
      @line.moveTo -lineWidth/2, 0
      @line.lineTo lineWidth/2, 0

      @width = @text.width + PADDING
      @height = @text.height + PADDING
      @text.anchor = {x:0.5, y:0.5}
      @text.position = {x:(@width)/2, y:(@height)/2 }
      @.addChild @text
      @.addChild @line
      @enabled = true
      @.hitArea = new PIXI.Rectangle(0, 0, @width, @height)
      @.interactive = true
      @.buttonMode = true
      #@.defaultCursor = 'pointer'
      @.activeTween = null
      @.mouseover = => @playStartHoverAnim()
      @.mouseout = => @playEndHoverAnim()
      @line.anchor = {x:0.5, y:0.5}
      @line.position = {x:@text.position.x, y:@text.height + UNDERLINE_PADDING}

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

    playStartHoverAnim: ->
      line = @line
      tween = new TWEEN.Tween({sx: 1.0}).to({sx:@lineScale}, LINE_GROW_TIME)
      tween.onUpdate -> line.scale = {x:@sx, y:1.0}
      if @activeTween?
        @activeTween.stop()
      tween.start()
      @activeTween = tween

    playEndHoverAnim: ->
      line = @line
      tween = new TWEEN.Tween({sx: line.scale.x}).to({sx:1.0}, LINE_GROW_TIME)
      tween.onUpdate ->
        line.scale = {x:@sx, y:1.0}
      if @activeTween?
        @activeTween.stop()
      tween.start()
      @activeTween = tween
