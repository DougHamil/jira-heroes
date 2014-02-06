define ['battle/animation', 'gfx/icon', 'gfx/styles', 'util', 'pixi', 'tween'], (Animation, Icon, STYLES, Util) ->
  FADE_TIME = 1000

  class DamageIndicator extends PIXI.DisplayObjectContainer
    constructor: (damage) ->
      super
      @text = new PIXI.Text damage.toString(), STYLES.DAMAGE_TEXT
      @text.anchor = {x:0.5, y:0.5}
      @text.setText damage.toString()
      @.addChild @text
      @width = @text.width
      @height = @text.height

    setDamage:(damage) ->
      @text.setText(damage.toString())

    animate: (damage)->
      @text.setText "-#{damage}"
      if damage is 0
        @text.setText ""
      @text.alpha = 1.0
      @visible = true
      animation = new Animation()
      animation.addPauseStep 1000, 'pause'
      animation.addTweenStep Util.fadeSpriteTween(@text, 0.0, FADE_TIME)
      animation.on 'complete', =>
        @visible = false
      return animation

