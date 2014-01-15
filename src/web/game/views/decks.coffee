define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->
  DECK_BUTTON_PADDING = 10

  class Decks extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Your Decks', GUI.STYLES.HEADING
      @backBtn = new GUI.TextButton 'Back'
      @createDeckBtn = new GUI.TextButton 'Create Deck'

      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'MainMenu'
      @createDeckBtn.position = {x:20, y:engine.HEIGHT - @createDeckBtn.height - 100}
      @createDeckBtn.onClick => @manager.activateView 'CreateDeck'

      @.addChild @heading
      @.addChild @backBtn
      @.addChild @createDeckBtn

    activate: ->
      activate = (decks) =>
        @deckButtons = []
        y = 50
        for deck in decks
          editDeck = (deck) => => @manager.activateView 'EditDeck', deck
          deckBtn = new GUI.DeckButton deck, JH.heroes[deck.hero.class]
          @.addChild deckBtn
          deckBtn.position = {x:0, y:y}
          deckBtn.onClick editDeck(deck)
          y += deckBtn.height + DECK_BUTTON_PADDING
          @deckButtons.push deckBtn
        @myStage.addChild @

      JH.GetAllDecks (decks) =>
        activate(decks)

    deactivate: ->
      @myStage.removeChild @
      for btn in @deckButtons
        @.removeChild btn
