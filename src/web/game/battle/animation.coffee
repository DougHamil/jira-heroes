define ['eventemitter', 'util', 'pixi'], (EventEmitter, Util) ->
  ###
  # An animation is a collection of tweens with extended support for events
  ###
  class Animation extends EventEmitter
    constructor: ->
      @steps = []

    # Nested animations
    addAnimationStep: (animation, id) ->
      step =
        id: id
        animation: animation
      @steps.push step

    addTweenStep: (tweens, id) ->
      if not tweens instanceof Array
        tweens = [tweens]
      if not id?
        id = @steps.length
      step =
        id: id
        tweens: tweens
      @steps.push step

    play: ->
      @_playNext(0) ->

    _playNext: (idx) ->
      if idx < @steps.length
        step = @steps[idx]
        if step.tweens?
          totalSteps = step.tweens.length
          onCompleteHandler =>
            totalSteps -= 1
            if totalSteps <= 0
              # Fire event indicating this step is finished
              @emit 'complete-step', step.id
              @_playNext(idx + 1)
          for tween in step.tweens
            tween.onComplete onCompleteHandler
            tween.start()
        else if step.animation?
          # Listen for completion of animation
          step.animation.on 'complete', =>
            @emit 'complete-step', step.id
            @_playNext(idx + 1)
          step.animation.play()
        @emit 'start-step', step.id
      else
        @emit 'complete'

