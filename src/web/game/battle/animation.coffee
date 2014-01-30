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

    addUnchainedAnimationStep:(animation, id) ->
      if not animation?
        return
      step =
        id: id
        animation: animation
        chained: false
      @steps.push step

    # Nested animations
    addAnimationStep: (animation, id) ->
      if not animation?
        return
      animationFunc = null
      if typeof animation is 'function'
        animationFunc = animation
        animation = null
      step =
        id: id
        animation: animation
        animationFunc: animationFunc
        chained: true
      @steps.push step

    addTweenStep: (tweens, id) ->
      tweenFunc = null
      if typeof tweens is 'function'
        tweenFunc = tweens
        tweens = null
      if not tweenFunc? and tweens not instanceof Array
        tweens = [tweens]
      if not id?
        id = @steps.length
      step =
        id: id
        tweens: tweens
        tweenFunc: tweenFunc
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
        if step.animationFunc?
          step.animation = step.animationFunc()
        if step.tweenFunc?
          step.tweens = step.tweenFunc()
          if step.tweens not instanceof Array
            step.tweens = [step.tweens]
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
          if step.chained
            @activeAnimation = step.animation
            # Listen for completion of animation
            @activeAnimation.on EVENT.COMPLETE, @_playNextHandler(step, idx)
            @activeAnimation.play()
          else
            step.animation.play()
            @_playNextHandler(step, idx)()
        @emit EVENT.START_STEP, step.id
      else
        @_complete()

    _complete: ->
      @activeTweens = null
      @activeAnimation = null
      @isPlaying = false
      @emit EVENT.COMPLETE

