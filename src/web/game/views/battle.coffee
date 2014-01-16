define ['jquery', 'jiraheroes', 'gui', 'client/battlemanager', 'engine', 'pixi'], ($, JH, GUI, BattleManager, engine) ->
  ###
  # This view displays the actual battle part of the game to the player
  ###
  class Battle extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super

    activate: (@battle) ->
      @myStage.addChild @
      @battleManager = new BattleManager @battle
      @battleManager.on 'connected', =>
        console.log "IM CONNECTED"

    @deactivate: ->
      @myStage.removeChild @
