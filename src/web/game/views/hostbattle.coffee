define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->
  class HostBattle extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Host a Battle', GUI.STYLES.HEADING
      @subheading = new PIXI.Text 'Pick a deck to battle with:', GUI.STYLES.TEXT
      @subheading.position = {x:20, y:@heading.position.y + @heading.height + 5}
      @backBtn = new GUI.TextButton 'Back'
      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'MainMenu'

      @.addChild @heading
      @.addChild @subheading
      @.addChild @backBtn

    hostBattleWithDeck: (deckId) ->
      if @decks[deckId]?
        JH.HostBattle deckId, (battle) =>
          @manager.activateView 'Battle', battle


    activate: ->
      activate = (decks) =>
        decks = decks.filter (d) -> d.cards.length is 30
        if decks.length > 0
          @decks = {}
          for deck in decks
            @decks[deck._id] = deck
          @deckList = new GUI.DeckPicker decks, JH.heroes
          @deckList.position = {x: 0, y: 100}
          @deckList.onDeckPicked (deckId) => @hostBattleWithDeck(deckId)
          @.addChild @deckList
        else
          @deckList = new PIXI.Text 'You do not own any full decks', GUI.STYLES.WARNING
          @deckList.position = {x:0, y:100}
          @.addChild @deckList
        @myStage.addChild @
      JH.GetAllDecks activate

    deactivate: ->
      @.removeChild @deckList
      @myStage.removeChild @
