define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->
  class Library extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Library', GUI.STYLES.HEADING

      @backBtn = new GUI.TextButton 'Back'
      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick =>
        @manager.activateView 'MainMenu'

      @.addChild @heading
      @.addChild @backBtn

    deactivate: ->
      @myStage.removeChild @

    activate: (@hero) ->
      # TODO: Get first page of card data
      @myStage.addChild @
