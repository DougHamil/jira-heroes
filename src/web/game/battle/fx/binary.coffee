define ['battle/fx/base', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (BaseFx, Animation, GUI, engine, Util) ->
  MOVE_TO_TARGET_TIME = 400
  RETURN_POS_TIME = 300
  NO_TARGET_SCALE_FACTOR = 1.5
  NO_TARGET_ANIM_TIME = 500
  TWINE_FREQUENCY = 5
  TWINE_AMPLITUDE = 20
  CAST_TWEEN_TIME = 1500

  ONE_TEXTURE = PIXI.Texture.fromImage '/media/images/fx/one.png'
  ZERO_TEXTURE = PIXI.Texture.fromImage '/media/images/fx/zero.png'

  ###
  # Beam a particle of 1s and 0s at the target(s)
  ###
  class BinaryFx extends BaseFx
    constructor: (@source, @targets, @data) ->
      super

    # Animate the source card moving to the target and then moving back
    _animateSingleTarget: (animator, sSprite, tSprite, animation)->
      animation.addAnimationStep @_beamTo(sSprite, tSprite)

    _animateMultiTarget: (animator, sSprite, animation)->
      animation.on 'start', =>
        parent = sSprite.parent
        parent.removeChild sSprite
        parent.addChild sSprite
      sourcePosition = Util.clone(sSprite.position)
      moveSourceTo = (target)-> ->
        Util.spriteTween(sSprite, sSprite.position, Util.clone(target.position), MOVE_TO_TARGET_TIME)
      for target in @targets
        animation.addTweenStep moveSourceTo(target), 'hit-target', target
        animation.addUnchainedAnimationStep @_tremble(target)
      animation.addTweenStep ->
        Util.spriteTween(sSprite, sSprite.position, sourcePosition, RETURN_POS_TIME)

    _animateNoTarget: (animator, sSprite, animation)->
      animation.on 'start', =>
        parent = sSprite.parent
        parent.removeChild sSprite
        parent.addChild sSprite
      sourceScale = Util.clone(sSprite.scale)
      animation.addTweenStep ->
        Util.scaleSpriteTween sSprite, NO_TARGET_SCALE_FACTOR, NO_TARGET_ANIM_TIME
      animation.addTweenStep ->
        Util.scaleSpriteTween sSprite, sourceScale, NO_TARGET_ANIM_TIME

    _beamTo: (source, target) ->
      animation = new Animation()
      emitter1 = new Proton.Emitter()
      emitter0 = new Proton.Emitter()
      emitter0.rate = new Proton.Rate(2, new Proton.Span(0.001, 0.015))
      emitter1.rate = new Proton.Rate(2, new Proton.Span(0.001, 0.015))
      emitter0.addInitialize(new Proton.Mass(1))
      emitter1.addInitialize(new Proton.Mass(1))
      emitter0.addInitialize(new Proton.ImageTarget(ZERO_TEXTURE))
      emitter1.addInitialize(new Proton.ImageTarget(ONE_TEXTURE))
      emitter0.addInitialize(new Proton.Life(0.5, 1))
      emitter1.addInitialize(new Proton.Life(0.5, 1))
      #emitter0.addInitialize(new Proton.Velocity(new Proton.Span(1, 2), new Proton.Span(1,2, true), 'polar'))

      #emitter0.addBehaviour(new Proton.Gravity(8))
      emitter0.addBehaviour(new Proton.Scale(new Proton.Span(1, 2), 0.5))
      emitter1.addBehaviour(new Proton.Scale(new Proton.Span(1, 2), 0.3))
      emitter0.addBehaviour(new Proton.Alpha(1, 0.5))
      emitter1.addBehaviour(new Proton.Alpha(1, 0.5))
      emitter0.addBehaviour(new Proton.Color('#00FF00', ['#ffff00', '#ffff11'], Infinity, Proton.easeOutSine))
      emitter1.addBehaviour(new Proton.Color('#00FF00', ['#ffff00', '#ffff11'], Infinity, Proton.easeOutSine))
      emitter0.addBehaviour(new Proton.Rotate(0, Proton.getSpan(-8, 9), 'add'))
      emitter1.addBehaviour(new Proton.Rotate(0, Proton.getSpan(-8, 9), 'add'))
      sPos = source.getCenterPosition()
      emitter0.p.x = sPos.x
      emitter0.p.y = sPos.y
      emitter1.p.x = sPos.x
      emitter1.p.y = sPos.y
      engine.proton.addEmitter(emitter0)
      engine.proton.addEmitter(emitter1)
      animation.addTweenStep =>
        sPos = Util.clone(source.getCenterPosition())
        tween0 = new TWEEN.Tween({x:0.0}).to({x:1.0}, CAST_TWEEN_TIME)
        tween0.onUpdate ->
          tPos = Util.clone(target.getCenterPosition())
          dir = Util.pointSubtract(tPos, sPos)
          unitDir = Util.vectorNormalize(dir)
          perp = {x:unitDir.y, y:-unitDir.x}
          percent = @x / 1.0
          sine = Math.sin((2 * Math.PI * percent) * TWINE_FREQUENCY)
          delta = sine * TWINE_AMPLITUDE
          emitter0.p.x = sPos.x + dir.x * percent + perp.x * delta
          emitter0.p.y = sPos.y + dir.y * percent + perp.y * delta
        tween1 = new TWEEN.Tween({x:0.0}).to({x:1.0}, CAST_TWEEN_TIME)
        tween1.onUpdate ->
          tPos = Util.clone(target.getCenterPosition())
          dir = Util.pointSubtract(tPos, sPos)
          unitDir = Util.vectorNormalize(dir)
          perp = {x:-unitDir.y, y:unitDir.x}
          percent = @x / 1.0
          sine = Math.sin((2 * Math.PI * percent) * TWINE_FREQUENCY)
          delta = sine * TWINE_AMPLITUDE
          emitter1.p.x = sPos.x + dir.x * percent + perp.x * delta
          emitter1.p.y = sPos.y + dir.y * percent + perp.y * delta
        return [tween0, tween1]
      animation.on 'complete', =>
        emitter0.stopEmit()
        emitter1.stopEmit()
      animation.on 'start', =>
        emitter0.emit()
        emitter1.emit()
      return animation

    _tremble: (sprite) ->
      animation = new Animation()
      jitterSteps = 5
      initialPosition = Util.clone(sprite.position)
      for i in [0...5]
        animation.addTweenStep ->
          return Util.spriteTween sprite, sprite.position, Util.pointJitter(sprite.position, 10), 50
      animation.addTweenStep =>
        return Util.spriteTween sprite, sprite.position, initialPosition, 50
      return animation

