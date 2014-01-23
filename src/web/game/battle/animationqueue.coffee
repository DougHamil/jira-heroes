define ['jquery', 'gui', 'engine', 'util', 'pixi'], ($, GUI, engine, Util) ->
  class AnimationQueue
    @queue = []

    ###
    # Enqueues a tween
    ###
    add: (tween) ->
      @queue.push tween

    ###
    # Runs all enqueued animations and starts a new queue
    # cb is called once the last tween has completed
    ###
    run: (cb) ->
      @_startNext(@queue, cb)
      @queue = []

    _startNext: (queue, cb) ->
      if queue.length > 0
        next = queue.shift()
        next.onComplete => @_startNext(queue, cb)
        next.start()
      else
        cb()
