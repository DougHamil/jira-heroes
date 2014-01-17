define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->
  class JoinBattle extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Join a Battle', GUI.STYLES.HEADING
      @deckPick = new PIXI.DisplayObjectContainer
      @subheading = new PIXI.Text 'Pick a deck to battle with:', GUI.STYLES.TEXT
      @subheading.position = {x:20, y:@heading.position.y + @heading.height + 5}
      @deckPick.addChild @subheading
      @deckPick.visible = false
      @backBtn = new GUI.TextButton 'Back'
      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'MainMenu'

      @.addChild @heading
      @.addChild @backBtn
      @.addChild @deckPick

    joinBattleWithDeck: (battleId, deckId) ->
      if battleId? and @decks[deckId]?
        JH.JoinBattle battleId, deckId, (battle) =>
          @manager.activateView 'Battle', battle

    onBattlePicked: (battleId) ->
      @pickedBattleId = battleId
      @deckPick.visible = true
      @battlePicker.visible = false

    activate: ->
      activate = (users, @battles, @decks) =>
        usersById = {}
        for user in users
          usersById[user._id] = user
        @battlePicker = new GUI.BattlePicker battles, usersById
        @battlePicker.onBattlePicked (battleId) => @onBattlePicked(battleId)
        @battlePicker.position = {x: 0, y:100}
        @.addChild @battlePicker

        decks = decks.filter (d) -> d.cards.length is 30
        if decks.length > 0
          @decks = {}
          for deck in decks
            @decks[deck._id] = deck
          @deckList = new GUI.DeckPicker decks, JH.heroes
          @deckList.position = {x: 0, y: 100}
          @deckList.onDeckPicked (deckId) => @joinBattleWithDeck(@pickedBattleId, deckId)
        else
          @deckList = new PIXI.Text 'You do not own any full decks', GUI.STYLES.WARNING
          @deckList.position = {x:0, y:100}
        @deckPick.addChild @deckList
        @deckPick.visible = false
        @myStage.addChild @
      JH.GetOpenBattles (battles) =>
        userIds = battles.map (b) -> b.users[0]
        battles = battles.filter (b) -> JH.user._id not in b.users
        JH.GetUsers userIds, (users) =>
          JH.GetAllDecks (decks) =>
            activate users, battles, decks

    deactivate: ->
      @.removeChild @battlePicker
      @deckPick.removeChild @deckList
      @myStage.removeChild @
