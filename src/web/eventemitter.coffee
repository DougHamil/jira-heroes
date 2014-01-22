define [], ->
  class EventEmitter
    constructor: ->
      @events = {}

    #---------------
    # Event Handling
    #---------------
    on: (event, cb) ->
      if not @events[event]?
        @events[event] = []
      @events[event].push cb

    emit: (event, args...) ->
      if @events[event]?
        for cb in @events[event]
          cb args...
