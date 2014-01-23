define ['eventemitter', 'util', 'pixi'], (EventEmitter, Util) ->
  EVENT =
    START: 'start'
    COMPLETE_STEP: 'complete-step'
    COMPLETE: 'complete'
    START_STEP: 'start-step'

  ###
  # Animation is a series of animation steps composed of tweens or other animations
  # Events are fired for each step as well as the completion of the entire animation
  ###
  class Animation extends EventEmitter
    constructor: ->
      super
      @steps = []

    # Nested animations
    addAnimationStep: (animation, id) ->
      if not animation?
        return
      step =
        id: id
        animation: animation
      @steps.push step

    addTweenStep: (tweens, id) ->
      if tweens not instanceof Array
        tweens = [tweens]
      if not id?
        id = @steps.length
      step =
        id: id
        tweens: tweens
      @steps.push step

    play: ->
      @emit EVENT.START
      @_playNext(0)

    _playNext: (idx) ->
      if idx < @steps.length
        step = @steps[idx]
        if step.tweens?
          totalSteps = step.tweens.length
          if totalSteps > 0
            onCompleteHandler = =>
              totalSteps -= 1
              if totalSteps <= 0
                # Fire event indicating this step is finished
                @emit EVENT.COMPLETE_STEP, step.id
                @_playNext(idx + 1)
            for tween in step.tweens
              tween.onComplete onCompleteHandler
              tween.start()
          else
            @emit EVENT.COMPLETE_STEP, step.id
            @_playNext(idx + 1)
        else if step.animation?
          # Listen for completion of animation
          step.animation.on EVENT.COMPLETE, =>
            @emit EVENT.COMPLETE_STEP, step.id
            @_playNext(idx + 1)
          step.animation.play()
        @emit EVENT.START_STEP, step.id
      else
        @emit EVENT.COMPLETE

