define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->

  class CreateDeck extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Create A Deck', GUI.STYLES.HEADING
      @backBtn = new GUI.TextButton 'Back'
      @createBtn = new GUI.TextButton 'Create'
      @heroButtons = []
      x = 100
      for heroId, hero of JH.heroes
        btn = new GUI.HeroButton hero
        btn.hero = hero
        @heroButtons.push btn
        btn.onClick (b) => @setSelectedHero(b)
        btn.position = {x:x, y: 100}
        x += btn.width + 100

      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'Decks'
      @createBtn.position = {x:20, y:engine.HEIGHT - @createBtn.height - 100}
      @createBtn.onClick => @createDeck()

      @.addChild @heading
      @.addChild @backBtn
      @.addChild @createBtn

      for heroBtn in @heroButtons
        @.addChild heroBtn

    setSelectedHero: (heroBtn) ->
      for otherBtn in @heroButtons
        otherBtn.setHighlight(false)
      heroBtn.setHighlight(true)
      @selectedHero = heroBtn.hero
      console.log @selectedHero
    createDeck: ->
      # TODO: Make a much prettier naming dialog
      deckName = window.prompt "Enter a name for your new deck:", "My New Deck"
      if deckName?
        @createBtn.disable()
        JH.CreateNewDeck deckName, @selectedHero._id, =>
          @manager.activateView 'Decks'

    activate: ->
      @setSelectedHero @heroButtons[0]
      @myStage.addChild @

    deactivate: ->
      @myStage.removeChild @
