define ['gfx/glyphtext','battle/animation', 'gfx/icon', 'gfx/styles', 'util', 'pixi', 'tween'], (GlyphText, Animation, Icon, STYLES, Util) ->
  FADE_TIME = 1000

  class ErrorMessage extends PIXI.DisplayObjectContainer
    constructor: () ->
      super
      @text = new GlyphText "<alert> ERROR DISPLAY", STYLES.ERROR_TEXT, 0xB22222, 64, true
      @text.anchor = {x:0.5, y:0.5}
      @width = @text.width
      @height = @text.height
      @visible = false
      @.addChild @text

    showError:(error) ->
      if @animation?
        @animation.stop()
        @animation = null
      @text.setText "<alert> #{error.message}", STYLES.ERROR_TEXT, 0xB22222,64, true
      #@text.position = {x:-@text.width/2,y:-@text.height/2}
      @text.alpha = 1.0
      @visible = true
      animation = new Animation()
      animation.addPauseStep 1000, 'pause'
      animation.addTweenStep Util.fadeSpriteTween(@text, 0.0, FADE_TIME)
      animation.on 'complete', =>
        @visible = false
      animation.play()
      @animation = animation
