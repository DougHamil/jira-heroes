define ['gfx/styles','util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  class Row
    constructor: (@origin, @widthPerElement, @padding) ->
      @elements = []

    getPositionOf: (element) ->
      for el, i in @elements
        if el is element
          return @getPositionAt(i)
      return null

    getPositionAt: (idx) -> return {x: @origin.x + (@widthPerElement * idx) + (@padding * idx), y: @origin.y}
    getNextPosition: -> return @getPositionAt(@elements.length)

    add:(el) ->
      @elements.push el

    remove: (el) ->
      @elements = @elements.filter (e) -> e isnt el

    getElementPositions: ->
      positions = []
      for i in [0...@elements.length]
        position = @getPositionAt(i)
        element = @elements[i]
        positions.push {position:position, element:element}
      return positions

