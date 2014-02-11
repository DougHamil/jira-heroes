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

    # Expanding ring of sprites with tint
    @SpriteRing: (config) ->
      emitter = @BasicEmitter()
      config.rate = if config.rate? then config.rate else 100
      emitter.rate = new Proton.Rate(config.rate, new Proton.Span(0.0001, 2))
      emitter.addInitialize new Proton.ImageTarget(config.texture)
      emitter.addInitialize new Proton.Life(config.life...)
      emitter.addBehaviour new Proton.Color(Util.hexColorToString(config.tint))

      emitter.addBehaviour new Proton.Alpha(2, 0.0)
      emitter.addInitialize new Proton.Velocity(new Proton.Span(0.5, 1), new Proton.Span(0, 360, true), 'polar')
      return emitter

