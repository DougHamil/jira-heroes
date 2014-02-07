define ['battle/animation', 'gfx/styles', 'util', 'pixi', 'tween'], (Animation, styles, Util) ->
  BG_TEXTURE = PIXI.Texture.fromImage "/media/images/fx/spark.png"
  class WinGraphic extends PIXI.DisplayObjectContainer
    constructor: (text, tint) ->
      super
      @text = new PIXI.Text text, styles.LARGE_TEXT
      @sprite = new PIXI.Sprite BG_TEXTURE
      @width = @sprite.width
      @height = @sprite.height
      @text.anchor = {x:0.5, y:0.5}
      @sprite.anchor = {x:0.5, y:0.5}
      @text.position = {x:@width/2, y:@height/2}
      @sprite.position = {x:@width/2, y:@height/2}
      @.addChild @sprite
      @.addChild @text
      @sprite.tint = tint

    animate: ->
      animation = new Animation()
      sprite = @sprite
      tween = new TWEEN.Tween(@sprite).to({rotation:3.14}, 800).repeat(Infinity).yoyo(false).onUpdate ->
        sprite.rotation = @rotation
      #tween.easing(TWEEN.Easing.Elastic.Out)
      tween.start()

      text = @text
      tween2 = new TWEEN.Tween({start:1}).to({start:1.8}, 800).repeat(Infinity).yoyo(true).onUpdate ->
        sprite.scale = {x:@start, y:@start}
      tween2.easing(TWEEN.Easing.Elastic.Out)
      tween2.start()
      tween2 = new TWEEN.Tween({start:1}).to({start:2.0}, 800).repeat(Infinity).yoyo(true).onUpdate ->
        text.scale = {x:@start, y:@start}
      tween2.easing(TWEEN.Easing.Elastic.Out)
      tween2.start()
      return animation

