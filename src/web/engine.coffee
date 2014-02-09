define ['jquery', 'pixi', 'tween'], ($, PIXI) ->
  window.PIXI = PIXI
  stage = new PIXI.Stage 0x112233, true
  renderer = new PIXI.autoDetectRenderer 1024, 768, $('#mainCanvas').get(0)

  # Bridge the Proton to Pixi.js gap
  transformSprite = (particleSprite, particle) ->
    particleSprite.position.x = particle.p.x
    particleSprite.position.y = particle.p.y
    particleSprite.scale.x = particle.scale
    particleSprite.scale.y = particle.scale
    particleSprite.anchor.x = 0.5
    particleSprite.anchor.y = 0.5
    particleSprite.alpha = particle.alpha
    particleSprite.rotation = particle.rotation * Math.PI / 180
    # Proton uses CSS color strings
    if particle.color?
      particleSprite.tint = parseInt("0x"+particle.color.substring(1), 16)

  proton = new Proton()
  protonRenderer = new Proton.Renderer('other', proton)

  engine =
    proton:proton
    stage:stage
    fxLayer:new PIXI.DisplayObjectContainer()
    renderer:renderer
    updateCallbacks:[]
    WIDTH: renderer.width
    HEIGHT: renderer.height
    timeMultiplier:1
    paused:false

  protonRenderer.onProtonUpdate = ->
  protonRenderer.onParticleCreated = (particle) ->
    particleSprite = new PIXI.Sprite(particle.target)
    particle.sprite = particleSprite
    engine.fxLayer.addChild(particle.sprite)
  protonRenderer.onParticleUpdate = (particle) ->
    transformSprite(particle.sprite, particle)
  protonRenderer.onParticleDead = (particle) ->
    engine.fxLayer.removeChild particle.sprite
  protonRenderer.start()

  animate = ->
    requestAnimFrame animate
    for callback in engine.updateCallbacks
      callback()
    engine.proton.update()
    engine.renderer.render engine.stage
    TWEEN.update()

  requestAnimFrame animate

  return engine
