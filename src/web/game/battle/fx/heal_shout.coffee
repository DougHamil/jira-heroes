define ['battle/fx/base', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (BaseFx, Animation, GUI, engine, Util) ->
  COLOR = 0x22B222
  CROSS_TEXTURE = PIXI.Texture.fromImage '/media/images/fx/cross.png'

  ###
  # Show little healing crosses from source
  ###
  class HealShout extends BaseFx
    constructor: (@source, @targets, @data) ->
      super

    # Animate the source card moving to the target and then moving back
    _animateSingleTarget: (animator, source, target, animation)->
      animation.addAnimationStep @_shout(animator, source)

    _animateMultiTarget: (animator, source, targets, animation)->
      animation.addAnimationStep @_shout(animator, source)

    _animateNoTarget: (animator, source, animation)->
      animation.addAnimationStep @_shout(animator, source)

    _shout: (animator, sourceObj) ->
      =>
        source = animator.getSprite(sourceObj)
        animation = new Animation()
        emitter1 = new Proton.Emitter()
        emitter1.rate = new Proton.Rate(10, new Proton.Span(0.001, 2))
        emitter1.addInitialize(new Proton.Mass(1))
        emitter1.addInitialize(new Proton.ImageTarget(CROSS_TEXTURE))
        emitter1.addInitialize(new Proton.Life(0.5, 2))
        emitter1.addInitialize(new Proton.Velocity(new Proton.Span(0.5, 1), new Proton.Span(1,20, true), 'polar'))

        #emitter1.addBehaviour(new Proton.Scale(new Proton.Span(1, 2), 0.3))
        emitter1.addBehaviour(new Proton.Alpha(2, 0.0))
        emitter1.addBehaviour(new Proton.Color(Util.hexColorToString(COLOR)))
        sPos = source.getCenterPosition()
        emitter1.p.x = sPos.x
        emitter1.p.y = sPos.y
        engine.proton.addEmitter(emitter1)
        animation.on 'start', =>
          emitter1.emit('once')
        return animation
