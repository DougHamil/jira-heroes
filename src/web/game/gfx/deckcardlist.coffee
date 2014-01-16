define ['gfx/styles', 'gfx/deckcardlistentry', 'util', 'engine', 'pixi', 'tween'], (STYLES, DeckCardListEntry, Util, engine) ->
  HEIGHT = engine.HEIGHT - 100
  WIDTH = engine.WIDTH / 4
  PADDING = 5
  ENTRY_HEIGHT = Math.floor(HEIGHT / 30)
  ENTRY_WIDTH = WIDTH - PADDING

  ###
  # Lists all of the cards within a deck in compact form for the Deck Editor
  ###
  class DeckCardList extends PIXI.DisplayObjectContainer
    constructor: (@deck, @cardClasses) ->
      super
      @bg = new PIXI.Graphics()
      @bg.width = WIDTH
      @bg.height = HEIGHT
      @bg.beginFill STYLES.BUTTON_COLOR
      @bg.drawRect 0, 0, @bg.width, @bg.height
      @width = @bg.width
      @height = @bg.height
      @.addChild @bg
      @update()

    update: ->
      if @entries?
        for cardId, entry of @entries
          @.removeChild entry
      @entries = {}
      @cardCounts = {}
      entryClickHandler = (cardId) => => @entryClickHandler(cardId) if @entryClickHandler?
      for card in @deck.cards
        if not @cardCounts[card]?
          @cardCounts[card] = 1
        else
          @cardCounts[card]++
        if @entries[card]?
          @entries[card].setCount(@cardCounts[card])
        else
          @entries[card] = new DeckCardListEntry ENTRY_WIDTH, ENTRY_HEIGHT, @cardClasses[card]
          @entries[card].onClick entryClickHandler(card)
          @.addChild @entries[card]
      @positionEntries()

    onCardEntryClicked: (@entryClickHandler) ->
    positionEntries: ->
      # 1 entry per card class
      orderedEntries = []
      for cardId, entry of @entries
        orderedEntries.push {entry:entry, energy:@cardClasses[cardId].energy}
      orderedEntries.sort (a,b) -> a.energy - b.energy
      y = 0
      for entry in orderedEntries
        entry = entry.entry
        entry.position = {x:0, y:y}
        y += ENTRY_HEIGHT





