define ['battle/row', 'gfx/styles','util', 'engine', 'pixi', 'tween'], (Row, STYLES, Util, engine) ->
  ###
  # Presents sprites as a row and allows sprites to be added and removed from the row
  ###
  class OrderedSpriteRow
    constructor: (@origin, @widthPerSprite, @padding, @animTime) ->
      @sprites = []

    reorder: (animStartCb, animEndPartialCb) ->
      index = 0
      for sprite in @sprites
        pos = @getPositionAt index
        if sprite.position.x isnt pos.x or sprite.position.y isnt pos.y
          sprite.tween = Util.spriteTween sprite, sprite.position, pos, @animTime
          if animStartCb?
            animStartCb(sprite)
          sprite.tween.start()
          if animEndPartialCb?
            sprite.tween.onComplete animEndPartialCb(sprite)
        index++

    getPositionAt: (idx) -> return {x: @origin.x + (@widthPerSprite * idx) + (@padding * idx), y: @origin.y}

    getNextPosition: -> return @getPositionAt(@sprites.length)

    addSprite: (sprite, animate, completeCb) ->
      position = @getNextPosition()
      if animate
        sprite.tween = Util.spriteTween sprite, sprite.position, position, @animTime
        sprite.tween.start()
        if completeCb?
          sprite.tween.onComplete completeCb
      else
        sprite.position = position
        if completeCb?
          completeCb()
      @sprites.push sprite
      return position

    removeSprite: (sprite) ->
      @sprites = @sprites.filter (s) -> s isnt sprite

    hasSprite: (sprite) ->
      return sprite in @sprites
