define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->

  class Decks extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Decks', GUI.STYLES.HEADING
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
        console.log decks
        @myStage.addChild @

      JH.GetAllDecks (decks) =>
        activate(decks)

    deactivate: ->
      @myStage.removeChild @
