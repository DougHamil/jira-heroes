define ['util', 'gui', 'engine', 'pixi', 'tween'], (Util, GUI, engine) ->
  TOKEN_COLORS = [
    0xAA2200
    0x0022AA
    0xAA00AA
    0x22AA00
  ]
  class CampaignMap extends PIXI.DisplayObjectContainer
    constructor: (@data) ->
      super
      @events = {}
      @heroTokens = {}
      console.log @data
      nodeClickHandler = (node) =>
        return =>
          @emit 'nodeClicked', node
      for node, pos of @data.class.map.nodes
        # TODO: This should be a sprite, not drawn like this
        g = new PIXI.Graphics()
        g.beginFill GUI.STYLES.BUTTON_COLOR
        g.drawCircle 0, 0, 20
        g.interactive = true
        g.hitArea = new PIXI.Circle 0, 0, 20
        g.position = {x:pos.x, y:pos.y}
        g.click = nodeClickHandler(node)
        @.addChild g
      for node, conns of @data.class.map.paths
        srcPos = @data.class.map.nodes[node]
        for conn in conns
          destPos = @data.class.map.nodes[conn]
          line = new PIXI.Graphics()
          line.lineStyle 10, GUI.STYLES.BUTTON_COLOR, 1
          line.moveTo srcPos.x, srcPos.y
          line.lineTo destPos.x, destPos.y
          @.addChild line
      for hero, node of @data.heroPositions
        @addHero @data.heroes[hero], node

    addHero: (hero, node) ->
      @data.heroes[hero.model._id] = hero
      pos = @data.class.map.nodes[node]
      g = null
      console.log "Adding hero: "
      console.log hero
      if hero.model.media.character.icon?
        texture = PIXI.Texture.fromImage hero.model.media.character.icon
        g = new PIXI.Sprite texture
        g.scale = {x:0.2, y:0.2}
      else
        g = new PIXI.Graphics()
        g.beginFill TOKEN_COLORS[Object.keys(@heroTokens).length]
        g.drawRect -10, -50, 20, 50
      g.anchor = {x:0.5, y:1.0}
      g.position.x = pos.x
      g.position.y = pos.y
      @.addChild g
      @heroTokens[hero.model._id] = g

    moveHero: (hero, node) ->
      token = @heroTokens[hero]
      from = token.position
      to = @data.class.map.nodes[node]
      Util.spriteTween(token, from, to, 500).easing(TWEEN.Easing.Cubic.Out).start()

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
