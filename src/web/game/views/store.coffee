define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->
  COST_SPRITE_PADDING = 10
  PAGE_POS =
    x: 50
    y: 100
  CARD_PADDING = 50
  CARDS_PER_ROW = 4
  ROWS_PER_PAGE = 2

  class Store extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Store', GUI.STYLES.HEADING
      @backBtn = new GUI.TextButton 'Back'

      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'MainMenu'

      @.addChild @heading
      @.addChild @backBtn

    deactivate: ->
      @myStage.removeChild @
      if JH.walletGraphic?
        @.removeChild JH.walletGraphic
      if JH.nameText?
        @.removeChild JH.nameText
      if @cardPicker?
        @.removeChild @cardPicker
        @cardPicker = null

    activate: (@hero) ->
      activate = (cards) =>
        @updateLibrary JH.user.library
        JH.cards = cards
        allCardIds = (id for id, card of JH.cards)
        allCardIds = allCardIds.filter (c) -> c not in JH.user.library
        @cardPicker = new GUI.CardPicker allCardIds, JH.cards
        @cardPicker.position = {x:20, y:100}
        @cardsById = {}
        @cardSprites = {}
        @cardPicker.onCardPicked (cardId) =>
          if not @library[cardId]?
            JH.AddCardToUserLibrary cardId, @onCardBought(cardId), @onCardBuyFail(cardId)
        for cardId, card of cards
          cardSprite = @cardPicker.getSprite(cardId)
          if cardSprite
            @cardSprites[cardId] = cardSprite
            @cardsById[card._id] = card
            cardSprite.onHoverStart (card) =>
              card.scale.x += 0.1
              card.scale.y += 0.1
            cardSprite.onHoverEnd (card) =>
              card.scale.x -= 0.1
              card.scale.y -= 0.1
        @addCostSprites JH.user, @library, @cardSprites, @cardsById
        @.addChild @cardPicker
        @.addChild JH.walletGraphic
        @.addChild JH.nameText
        @myStage.addChild @

      if not JH.cards?
        JH.GetAllCards activate
      else
        activate(JH.cards)

    updateLibrary: (userLibrary) ->
      @library = {}
      for cardId in userLibrary
        @library[cardId] = true

    onCardBuyFail: (cardId) ->
      =>
        console.log arguments
        console.log "Card buying failed for card #{cardId}"

    onCardBought: (cardId) ->
      =>
        JH.GetUser (user) =>
          JH.user = user
          @updateLibrary user.library
          @addCostSprites()
          JH.walletGraphic.update user.wallet
          @cardSprites[cardId].onClick ->

    updateCostSprite: (cardId) ->
      card = @cardsById[cardId]
      cardSprite = @cardSprites[cardId]
      if cardSprite.costSprite?
        cardSprite.costSprite.update(@canAfford(card.cost, JH.user.wallet), @library[cardId]?)
      else
        costSprite = @createCostSprite(cardSprite, card.cost, @canAfford(card.cost, JH.user.wallet), @library[cardId]?)
        costSprite.position = {x:cardSprite.width/2, y:cardSprite.height/2 - costSprite.height}
        cardSprite.costSprite = costSprite
        cardSprite.addChild costSprite

    addCostSprites: ->
      for cardId, card of @cardsById
        @updateCostSprite cardId

    canAfford: (cost, wallet) ->
      for currency, amount of cost
        if wallet[currency] < amount
          return false
      return true

    createCostSprite: (cardSprite, cost, canAfford, isOwned) ->
      return new GUI.CardCost cost, canAfford, isOwned
