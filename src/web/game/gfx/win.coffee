define ['battle/animation', 'gfx/styles', 'util', 'engine', 'pixi', 'tween'], (Animation, styles, Util, engine) ->
  BG_TEXTURE = PIXI.Texture.fromImage "/media/images/fx/spark.png"
  CONFETTI_TEXTURE = PIXI.Texture.fromImage '/media/images/fx/square_small.png'

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
      #@.addChild @sprite
      @.addChild @text
      @sprite.tint = tint

      @emitters = []
      for i in [0...5]
        @emitters.push(@_confetti())

    _confetti: ->
      emitter = new Proton.BehaviourEmitter()
      emitter.rate = new Proton.Rate(new Proton.Span(150, 200), new Proton.Span(0,2))
      emitter.addInitialize new Proton.Mass(1)
      emitter.addInitialize new Proton.ImageTarget(CONFETTI_TEXTURE)
      emitter.addInitialize new Proton.Life(2, 3)
      emitter.addInitialize new Proton.Velocity(new Proton.Span(3, 9), new Proton.Span(0, 360, true), 'polar')

      emitter.addBehaviour new Proton.Gravity(8)
      emitter.addBehaviour new Proton.Scale(new Proton.Span(0.5, 1), 0.3)
      emitter.addBehaviour new Proton.Color('random')
      emitter.addBehaviour new Proton.Alpha(1, 0.5)
      emitter.addBehaviour new Proton.Rotate(0, Proton.getSpan(-8, 9), 'add')

      #emitter.addSelfBehaviour new Proton.Gravity(5)
      emitter.addSelfBehaviour new Proton.RandomDrift(50, 50, .1)
      emitter.addSelfBehaviour new Proton.CrossZone(new Proton.RectZone(50,-200, 953, -100), 'bound')

      engine.proton.addEmitter(emitter)
      return emitter

    animate: (emit)->
      animation = new Animation()
      if emit
        sprite = @sprite
        tween = new TWEEN.Tween(@sprite).to({rotation:3.14}, 800).repeat(Infinity).yoyo(false).onUpdate ->
          sprite.rotation = @rotation
        #tween.easing(TWEEN.Easing.Elastic.Out)
        tween.start()

        for emitter in @emitters
          emitter.emit()

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

