define ['battle/animation', 'gfx/styles', 'util', 'engine', 'pixi', 'tween'], (Animation, styles, Util, engine) ->
  BG_COLOR = 0x3399BB
  BG_ALPHA = 0.8
  BG_RECT =
    x:0
    y:125
    width:800
    height:250
  POS =
    x:engine.WIDTH/2
    y:engine.HEIGHT/2
  HOLD_DIST = 50
  WIPE_TIME = 500
  HOLD_TIME = 4000
  class AchievementNote extends PIXI.DisplayObjectContainer
    constructor: (@ach) ->
      super
      @textInner = new PIXI.Text "Achievement Unlocked!", styles.TEXT
      @name = new PIXI.Text @ach.displayName, styles.LARGE_TEXT
      @desc = new PIXI.Text @ach.description, styles.TEXT
      @text = new PIXI.DisplayObjectContainer()
      @bg = @_buildBg()
      @width = @bg.width
      @height = @bg.height
      @bg.position = @_bgStartPos()
      @name.position.y += @textInner.height + 20
      @desc.position.y = @name.position.y + @name.height + 20
      @text.addChild @textInner
      @text.addChild @name
      @text.addChild @desc
      @text.position = @_textStartPos()
      @.addChild @bg
      @.addChild @text

    _buildBg: ->
      bg = new PIXI.Graphics()
      bg.beginFill BG_COLOR, BG_ALPHA
      bg.drawRect BG_RECT.x, BG_RECT.y, BG_RECT.width, BG_RECT.height
      bg.endFill()
      bg.width = BG_RECT.width
      bg.height = BG_RECT.height
      return bg

    _textStartPos: -> {x:-@desc.width, y:POS.y - @desc.height/2}
    _textHoldPos: -> {x:POS.x - @desc.width/2, y:POS.y - @desc.height/2}
    _textEndPos: -> {x:POS.x + engine.WIDTH, y:POS.y - @desc.height/2}

    _bgStartPos: -> {x:engine.WIDTH, y:POS.y - @bg.height/2}
    _bgHoldPos: -> {x:POS.x - @bg.width/2, y:POS.y - @bg.height/2}
    _bgEndPos: -> {x:-@bg.width, y:POS.y - @bg.height/2}

    onAnimationComplete: (@completeCallback) ->

    animate: ->
      animation = new Animation()
      animation.on 'start', =>
        @bg.position = @_bgStartPos()
        @text.position = @_textStartPos()

      animation.on 'complete', =>
        @completeCallback?()

      # Move in
      animation.addTweenStep =>
        bgTween = Util.spriteTween @bg, @bg.position, @_bgHoldPos(), WIPE_TIME
        bgTween.easing(TWEEN.Easing.Cubic.Out)
        textTween = Util.spriteTween @text, @text.position, @_textHoldPos(), WIPE_TIME
        text = @text
        textTween.onUpdate ->
          text.position.x = @x
          text.position.y = @y
          console.log text.position
        textTween.easing(TWEEN.Easing.Cubic.Out)
        return [bgTween, textTween]
      # Pan and hold
      animation.addTweenStep =>
        bgEndPos = @_bgHoldPos()
        bgEndPos.x -= HOLD_DIST
        bgTween = Util.spriteTween @bg, @bg.position, bgEndPos, HOLD_TIME
        #bgTween.easing(TWEEN.Easing.Cubic.Out)
        textEndPos = @_textHoldPos()
        textTween = Util.spriteTween @text, @text.position, textEndPos, HOLD_TIME
        #textTween.easing(TWEEN.Easing.Cubic.Out)
        return [bgTween, textTween]
      # Move out
      animation.addTweenStep =>
        bgTween = Util.spriteTween @bg, @bg.position, @_bgEndPos(), WIPE_TIME
        bgTween.easing(TWEEN.Easing.Cubic.Out)
        textTween = Util.spriteTween @text, @text.position, @_textEndPos(), WIPE_TIME
        textTween.easing(TWEEN.Easing.Cubic.Out)
        return [bgTween, textTween]
      return animation

