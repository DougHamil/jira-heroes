define ['gfx/styles', 'util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  TAB_TEXTURE = PIXI.Texture.fromImage '/media/images/end_turn_tab.png'
  TAB_WIDTH = 128
  TAB_HEIGHT = 128

  YOUR_TURN_TINT = 0x3399BB
  YOUR_TURN_NO_OPTIONS_TINT = 0x22B222
  ENEMY_TURN_TINT = 0xBBBBBB
  DRAG_DISTANCE = 324 * (TAB_HEIGHT/512)

  ANIM_TIME = 500

  class EndTurnButton extends PIXI.DisplayObjectContainer
    constructor: (isYourTurn) ->
      super
      @width = TAB_WIDTH
      @height = TAB_HEIGHT
      @bg = new PIXI.Sprite TAB_TEXTURE
      @bg.width = @width
      @bg.height = @height
      @bgOrigin = -DRAG_DISTANCE
      @bg.position = {x:-@bg.width/2, y:@bgOrigin}
      @bg.tint = YOUR_TURN_TINT
      @endTurnText = new PIXI.Text "End Turn", STYLES.TEXT
      @endTurnText.anchor = {x:0.5, y:0}
      @endTurnTextOrigin = @bgOrigin
      @endTurnText.position = {x:0, y:@endTurnTextOrigin}
      @statusText = new PIXI.Text "Your Turn", STYLES.TEXT
      @statusText.anchor = {x:0.5, y:0}
      @statusTextOrigin = 0
      @statusText.position = {x:0, y:@statusTextOrigin}

      @.addChild @bg
      @.addChild @statusText
      @.addChild @endTurnText

      @.hitArea = new PIXI.Rectangle -@width/2, @bgOrigin, @width, @height
      @.interactive = true
      @dragging = false
      @percentPulled = 0

      @.mousedown = =>
        if not @tween?
          @dragging = true
          @mouseStartPos = @stage.getMousePosition().clone()

      @.mouseup = => @_released() if @dragging

    setIsYourTurn: (isYourTurn) ->
      @interactive = isYourTurn
      if isYourTurn
        @statusText.setText "Your Turn"
        @bg.tint = YOUR_TURN_TINT
      else
        @statusText.setText "Enemy Turn"
        @bg.tint = ENEMY_TURN_TINT

    onClick: (@clickCallback) ->

    onMouseUp: (pos) ->
      if @dragging?
        @_released()

    update: ->
      if @dragging
        mousePos = @stage.getMousePosition().clone()
        deltaY = mousePos.y - @mouseStartPos.y
        if deltaY > DRAG_DISTANCE
          deltaY = DRAG_DISTANCE
        if deltaY < 0
          deltaY = 0
        if deltaY >= 0
          @bg.position.y = @bgOrigin + deltaY
          @statusText.position.y = @statusTextOrigin + deltaY
          @endTurnText.position.y = @endTurnTextOrigin + deltaY
        @percentPulled = deltaY / DRAG_DISTANCE

    _released: ->
      @dragging = false
      percent = @percentPulled
      @percentPulled = 0
      y = @bg.position.y - @bgOrigin
      bg = @bg
      st = @statusText
      et = @endTurnText
      bgOrigin = @bgOrigin
      stOrigin = @statusTextOrigin
      etOrigin = @endTurnTextOrigin
      tween = new TWEEN.Tween({y:y}).to({y:0}, ANIM_TIME).easing(TWEEN.Easing.Bounce.Out).onUpdate ->
        bg.position.y = bgOrigin + @y
        st.position.y = stOrigin + @y
        et.position.y = etOrigin + @y

      tween.onComplete =>
        if percent > 0.9
          @clickCallback?()
        @tween = null
      tween.start()
      @tween = tween

