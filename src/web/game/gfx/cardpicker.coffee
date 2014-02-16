define ['gfx/textbutton', 'gfx/styles', 'gfx/card', 'gfx/pagedcardgrid', 'util', 'engine', 'pixi', 'tween'], (TextButton, STYLES, Card, PagedCardGrid, Util, engine) ->
  HEIGHT = engine.HEIGHT - 100
  WIDTH = engine.WIDTH - engine.WIDTH / 4

  ###
  # Presents an interface to allow the user to pick a card from the list of avaiable cards
  ###
  class CardPicker extends PIXI.DisplayObjectContainer
    constructor: (@cards, @cardClasses) ->
      super
      @cardsByHero = {}
      for card in @cards
        clazz = @cardClasses[card]
        if clazz.heroRequirement? and clazz.heroRequirement.length > 0
          for hero in clazz.heroRequirement
            if not @cardsByHero[hero]?
              @cardsByHero[hero] = []
            @cardsByHero[hero].push card
        else
          if not @cardsByHero.common?
            @cardsByHero.common = []
          @cardsByHero.common.push card
      @cardSprites = {}
      for card in @cards
        onClick = (cardId) => =>
          if @onCardPickedCallback?
            @onCardPickedCallback(cardId)
        sprite = Card.FromClass @cardClasses[card]
        sprite.onClick onClick(card)
        @cardSprites[card] = sprite
      @cardGridsByHero = {}
      @buttonsByHero = {}
      for hero, cards of @cardsByHero
        _btnClick = (h) => =>
          if @activeCardGrid?
            @activeCardGrid.visible = false
          @cardGridsByHero[h].visible = true
          @activeCardGrid = @cardGridsByHero[h]
        sprites = cards.map (c) => @cardSprites[c]
        cardGrid = new PagedCardGrid WIDTH, HEIGHT, 10, 4, 2, sprites
        WIDTH = cardGrid.width
        HEIGHT = cardGrid.height
        @cardGridsByHero[hero] = cardGrid
        button = new TextButton hero, STYLES.TEXT
        button.onClick _btnClick(hero)
        @buttonsByHero[hero] = button

      @bg = new PIXI.Graphics()
      @bg.width = WIDTH
      @bg.height = HEIGHT
      @bg.beginFill STYLES.DARK_BACKGROUND_COLOR
      @bg.drawRect 0, 0, @bg.width, @bg.height
      @bg.alpha = 0.5
      @width = @bg.width
      @height = @bg.height
      @.addChild @bg

      idx = 1
      for hero, btn of @buttonsByHero
        if hero isnt 'common'
          btn.position.x = idx * 150
          btn.position.y = 0
          idx++
        @.addChild btn

      for hero, grid of @cardGridsByHero
        @.addChild grid
        grid.position.y += 40
        grid.visible = false
        if hero is 'common'
          @activeCardGrid = grid
          grid.visible = true


    getSprite: (cardId) -> return @cardSprites[cardId]

    onCardPicked: (@onCardPickedCallback) ->
