define ['gfx/styles', 'util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  TAB_TEXTURE = PIXI.Texture.fromImage '/media/images/end_turn_tab.png'
  TAB_WIDTH = 128
  TAB_HEIGHT = 128
  DRAG_DISTANCE = 324 * (TAB_HEIGHT/512)

  ANIM_TIME = 500

  class PullTab extends PIXI.DisplayObjectContainer
    constructor: (activeText, inactiveText, confirmText, @activeTint, @inactiveTint) ->
      super
      @width = TAB_WIDTH
      @height = TAB_HEIGHT
      @bg = new PIXI.Sprite TAB_TEXTURE
      @bg.width = @width
      @bg.height = @height
      @bgOrigin = -DRAG_DISTANCE
      @bg.position = {x:-@bg.width/2, y:@bgOrigin}
      @bg.tint = @activeTint
      @confirmText = new PIXI.Text confirmText, STYLES.TEXT
      @confirmText.anchor = {x:0.5, y:0}
      @confirmTextOrigin = @bgOrigin
      @confirmText.position = {x:0, y:@confirmTextOrigin}
      @activeText = new PIXI.Text activeText, STYLES.TEXT
      @activeText.anchor = {x:0.5, y:0}
      @activeTextOrigin = 0
      @activeText.position = {x:0, y:@activeTextOrigin}
      @inactiveText = new PIXI.Text inactiveText, STYLES.TEXT
      @inactiveText.anchor = {x:0.5, y:0}
      @inactiveTextOrigin = 0
      @inactiveText.position = {x:0, y:@inactiveTextOrigin}

      @.addChild @bg
      @.addChild @activeText
      @.addChild @inactiveText
      @.addChild @confirmText

      @.hitArea = new PIXI.Rectangle -@width/2, @bgOrigin, @width, @height
      @.interactive = true
      @dragging = false
      @percentPulled = 0
      @.mousedown = =>
        if not @tween?
          @dragging = true
          @mouseStartPos = @stage.getMousePosition().clone()
      @.mouseup = => @_released() if @dragging
      @setActive(true)

    setActive:(isActive) ->
      @activeText.visible = isActive
      @inactiveText.visible = !isActive
      @bg.tint = if isActive then @activeTint else @inactiveTint
      @interactive = isActive

    setTint: (tint) ->
      @bg.tint = tint

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
          @activeText.position.y = @activeTextOrigin + deltaY
          @confirmText.position.y = @confirmTextOrigin + deltaY
        @percentPulled = deltaY / DRAG_DISTANCE

    _released: ->
      @dragging = false
      percent = @percentPulled
      @percentPulled = 0
      y = @bg.position.y - @bgOrigin
      bg = @bg
      st = @activeText
      et = @confirmText
      bgOrigin = @bgOrigin
      stOrigin = @activeTextOrigin
      etOrigin = @confirmTextOrigin
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

