define ['jquery', 'tween', 'pixi'], ($) ->
  stage = new PIXI.Stage 0xEDC951, true
  renderer = new PIXI.autoDetectRenderer 1000, 800, $('#mainCanvas').get(0)

  engine =
    stage:stage
    renderer:renderer
    updateCallbacks:[]
    WIDTH: renderer.width
    HEIGHT: renderer.height
    timeMultiplier:1
    paused:false

  lastTime = new Date()
  animate = ->
    requestAnimFrame animate
    for callback in engine.updateCallbacks
      callback()
    engine.renderer.render engine.stage
    time = new Date()
    deltaTime = time - lastTime
    lastTime = time
    TWEEN.tick deltaTime * engine.timeMultiplier, engine.paused

  requestAnimFrame animate

  return engine
