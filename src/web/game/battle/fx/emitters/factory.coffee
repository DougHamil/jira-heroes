define ['battle/animation', 'gui', 'engine', 'util', 'pixi'], (Animation, GUI, engine, Util) ->
  ###
  # Basic emitters creation
  ###
  class EmitterFactory
    constructor: ->
      super

    @BasicEmitter: ->
      emitter = new Proton.Emitter()
      emitter.addInitialize new Proton.Mass(1)
      engine.proton.addEmitter(emitter)
      return emitter

    @SpriteFountain: (config) ->
      emitter = @BasicEmitter()
      velocityStart = config.vel0 || 10
      velocityEnd = config.vel1 || 20
      gravity = config.gravity || 8
      config.rate = if config.rate? then config.rate else 100
      config.rateSpan = if config.rateSpan then config.rateSpan else new Proton.Span(0.0001, 0.0001)
      config.angle = config.angle || 30
      emitter.rate = new Proton.Rate(config.rate, config.rateSpan)
      emitter.addInitialize new Proton.ImageTarget(config.texture)
      emitter.addInitialize new Proton.Life(config.life...)
      emitter.addBehaviour new Proton.Scale(new Proton.Span(0.5, 1), 0.3)
      emitter.addBehaviour new Proton.Gravity(gravity)
      if not config.tint? or config.tint is 'random'
        emitter.addBehaviour new Proton.Color 'random'
      else
        emitter.addBehaviour new Proton.Color(Util.hexColorToString(config.tint))
      emitter.addBehaviour new Proton.Rotate(0, Proton.getSpan(-8, 9), 'add')
      emitter.addBehaviour new Proton.Alpha(2, 0.0)
      emitter.addInitialize new Proton.Velocity(new Proton.Span(velocityStart, velocityEnd), new Proton.Span(0, config.angle, true), 'polar')
      return emitter

    # Expanding ring of sprites with tint
    @SpriteRing: (config) ->
      emitter = @BasicEmitter()
      velocityStart = config.vel0 || 0.5
      velocityEnd = config.vel1 || 1.0
      config.rate = if config.rate? then config.rate else 100
      emitter.rate = new Proton.Rate(config.rate, new Proton.Span(0.0001, 2))
      emitter.addInitialize new Proton.ImageTarget(config.texture)
      emitter.addInitialize new Proton.Life(config.life...)
      emitter.addBehaviour new Proton.Color(Util.hexColorToString(config.tint))

      emitter.addBehaviour new Proton.Alpha(2, 0.0)
      emitter.addInitialize new Proton.Velocity(new Proton.Span(velocityStart, velocityEnd), new Proton.Span(0, 360, true), 'polar')
      return emitter

