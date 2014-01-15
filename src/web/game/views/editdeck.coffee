define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->
  DECK_BUTTON_PADDING = 10

  class EditDeck extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Edit Deck', GUI.STYLES.HEADING
      @backBtn = new GUI.TextButton 'Back'

      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'Decks'

      @.addChild @heading
      @.addChild @backBtn

    onCardPicked: (cardId) ->
      @deck.cards.push cardId
      @cardList.update()

    activate: (@deck) ->
      @deckTitle = new PIXI.Text @deck.name, GUI.STYLES.TEXT
      @deckTitle.position = {x:20, y:@heading.height + 10}
      @cardList = new GUI.DeckCardList @deck, JH.cards
      @cardList.position = {x:engine.WIDTH - @cardList.width,y:50}
      @cardPicker = new GUI.CardPicker JH.user.library, JH.cards
      @cardPicker.onCardPicked (cardId) => @onCardPicked(cardId)
      @.addChild @deckTitle
      @.addChild @cardList
      @.addChild @cardPicker
      @myStage.addChild @

    deactivate: ->
      @myStage.removeChild @
      @.removeChild @deckTitle
      @.removeChild @cardList
      @.removeChild @cardPicker
