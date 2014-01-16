define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->
  DECK_BUTTON_PADDING = 10
  MAX_DECK_SIZE = 30

  class EditDeck extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Edit Deck', GUI.STYLES.HEADING
      @backBtn = new GUI.TextButton 'Back'
      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'Decks'

      @saveBtn = new GUI.TextButton 'Save'
      @saveBtn.position = {x:20, y:@backBtn.position.y - @saveBtn.height - 20}
      @saveBtn.onClick => @saveDeck()

      @.addChild @heading
      @.addChild @backBtn
      @.addChild @saveBtn

    saveDeck: ->
      @saveBtn.disable()
      JH.SetDeckCards @deck._id, @deck.cards, =>
        @saveBtn.enable()
        @manager.activateView 'Decks'

    removeCard: (cardId) ->
      if cardId in @deck.cards
        @deck.cards.splice @deck.cards.indexOf(cardId), 1
        @cardList.update()
        @updateCardCount()

    onCardPicked: (cardId) ->
      if @deck.cards.length < MAX_DECK_SIZE
        @deck.cards.push cardId
        @cardList.update()
        @updateCardCount()
      else
        alert 'You may not have more than '+MAX_DECK_SIZE+' cards in a single deck.'

    updateCardCount: ->
      @cardCount.setText "#{@deck.cards.length}/#{MAX_DECK_SIZE}"

    activate: (@deck) ->
      @cardList = new GUI.DeckCardList @deck, JH.cards
      @cardList.position = {x:engine.WIDTH - @cardList.width,y:50}
      @cardList.onCardEntryClicked (cardId) => @removeCard(cardId)
      @cardPicker = new GUI.CardPicker JH.user.library, JH.cards
      @cardPicker.onCardPicked (cardId) => @onCardPicked(cardId)
      @cardPicker.position = {x: 20, y: 50}
      @deckTitle = new PIXI.Text @deck.name, GUI.STYLES.TEXT
      @deckTitle.position = {x:@cardList.position.x, y:@cardList.position.y - @deckTitle.height}
      @cardCount = new PIXI.Text "#{@deck.cards.length}/#{MAX_DECK_SIZE}", GUI.STYLES.TEXT
      @cardCount.position = {x:@cardList.position.x + (@cardList.width/2) - @cardCount.width/2, y:@cardList.position.y + @cardList.height}
      @.addChild @cardList
      @.addChild @cardPicker
      @.addChild @deckTitle
      @.addChild @cardCount
      @myStage.addChild @

    deactivate: ->
      @myStage.removeChild @
      @.removeChild @cardList
      @.removeChild @cardPicker
      @.removeChild @deckTitle
      @.removeChild @cardCount
