define ['gfx/styles','util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  BASE_ANGLE = 0
  class Fan
    constructor: (@origin, @widthPerElement, @padding) ->
      @elements = []

    getPositionOf: (element) ->
      for el, i in @elements
        if el is element
          return @getPositionAt(i)
      return null
    getRotationOf: (element) ->
      for el, i in @elements
        if el is element
          return @getRotationAt(i)
      return null

    getPositionAt: (idx) ->
      return {x: @origin.x + (@widthPerElement * idx) + (@padding * idx), y: @origin.y}
    getRotationAt: (idx) ->
      rotationPerItem = @elements.length /  60
      return BASE_ANGLE + idx * rotationPerItem
    getNextPosition: -> return @getPositionAt(@elements.length)
    getNextRotation: -> return @getRotationAt(@elements.length)

    add:(el) ->
      @elements.push el

    remove: (el) ->
      @elements = @elements.filter (e) -> e isnt el

    getElements: -> return @elements
    getElementPositions: ->
      positions = []
      for i in [0...@elements.length]
        position = @getPositionAt(i)
        rotation = @getRotationAt(i)
        element = @elements[i]
        positions.push {rotation:rotation, position:position, element:element}
      return positions

