define ['gfx/styles', 'gfx/deckbutton', 'util', 'engine', 'pixi', 'tween'], (STYLES, DeckButton, Util, engine) ->
  HEIGHT = engine.HEIGHT - 100
  WIDTH = engine.WIDTH - engine.WIDTH / 4
  DECK_BUTTON_PADDING = 10

  ###
  # Provides an interface for selecting a deck
  ###
  class DeckPicker extends PIXI.DisplayObjectContainer
    constructor: (@decks, @heroes) ->
      super
      @deckButtons = {}
      y = 0
      onDeckButtonClicked = (deckId) => => @onDeckPickedCallback(deckId) if @onDeckPickedCallback?
      for deck in @decks
        deckBtn = new DeckButton deck, @heroes[deck.hero.class]
        @.addChild deckBtn
        deckBtn.position = {x:0, y:y}
        deckBtn.onClick onDeckButtonClicked(deck._id)
        y += deckBtn.height + DECK_BUTTON_PADDING
        @deckButtons[deck._id] = deckBtn

    onDeckPicked: (@onDeckPickedCallback) ->
    setHighlight: (deckId, highlight) ->
      @deckButtons[deckId].setHighlight(highlight)
