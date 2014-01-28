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

    clearEvent: (event) ->
      if @events[event]?
        @events[event] = []

    emit: (event, args...) ->
      if @events[event]?
        for cb in @events[event]
          cb args...
