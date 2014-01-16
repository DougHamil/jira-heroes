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

    onDeckPicked: (deckId) ->
      @manager.activateView 'EditDeck', (@decks.filter((d) -> d._id is deckId))[0]

    activate: ->
      activate = (@decks) =>
        @deckPicker = new GUI.DeckPicker decks, JH.heroes
        @deckPicker.onDeckPicked (deckId) => @onDeckPicked(deckId)
        @deckPicker.position = {x:0, y:50}
        @.addChild @deckPicker
        @myStage.addChild @

      JH.GetAllDecks (decks) =>
        activate(decks)

    deactivate: ->
      @.removeChild @deckPicker
      @myStage.removeChild @
