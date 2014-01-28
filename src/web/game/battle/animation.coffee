define ['eventemitter', 'util', 'pixi'], (EventEmitter, Util) ->
  EVENT =
    START: 'start'
    COMPLETE_STEP: 'complete-step'
    COMPLETE: 'complete'
    START_STEP: 'start-step'
    STOPPED: 'stopped'

  ###
  # Animation is a series of animation steps composed of tweens or other animations
  # Events are fired for each step as well as the completion of the entire animation
  ###
  class Animation extends EventEmitter
    constructor: ->
      super
      @isPlaying = false
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

    stop: ->
      if @isPlaying
        if @activeTweens?
          for tween in @activeTweens
            tween.stop()
        else if @activeAnimation?
          @activeAnimation.stop()
        @_complete()
        @emit EVENT.STOPPED

    play: ->
      @isPlaying = true
      @emit EVENT.START
      @_playNext(0)

    _playNextHandler: (step, idx) ->
      =>
        if @isPlaying
          # Fire event indicating this step is finished
          @emit EVENT.COMPLETE_STEP, step.id
          @emit EVENT.COMPLETE_STEP + '-' + step.id
          @activeTweens = null
          @activeAnimation = null
          @_playNext(idx + 1)

    _playNext: (idx) ->
      if idx < @steps.length
        step = @steps[idx]
        if step.tweens?
          totalSteps = step.tweens.length
          if totalSteps > 0
            @activeTweens = step.tweens
            onCompleteHandler = =>
              totalSteps -= 1
              if totalSteps <= 0
                @_playNextHandler(step, idx)()
            for tween in step.tweens
              tween.onComplete onCompleteHandler
              tween.start()
          else
            @_playNextHandler(step, idx)()
        else if step.animation?
          @activeAnimation = step.animation
          # Listen for completion of animation
          @activeAnimation.on EVENT.COMPLETE, @_playNextHandler(step, idx)
          @activeAnimation.play()
        @emit EVENT.START_STEP, step.id
      else
        @_complete()

    _complete: ->
      @activeTweens = null
      @activeAnimation = null
      @isPlaying = false
      @emit EVENT.COMPLETE

