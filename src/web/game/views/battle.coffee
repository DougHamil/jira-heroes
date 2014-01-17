define ['jquery', 'jiraheroes', 'gui', 'client/battlemanager', 'engine', 'pixi'], ($, JH, GUI, BattleManager, engine) ->
  ###
  # This view displays the actual battle part of the game to the player
  ###
  class Battle extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @statusText = new PIXI.Text 'Hosting battle...', GUI.STYLES.TEXT
      @setStatusText 'Connecting to battle...'
      @.addChild @statusText

    setStatusText: (text) ->
      @statusText.setText text

    onBattleStatus: (status) ->
      if status? and status.id is 'BATTLE_NOT_READY'
        @setStatusText 'Waiting for opponent to join...'

    activate: (@battle) ->
      @myStage.addChild @
      @battleManager = new BattleManager JH.user, @battle
      @battleManager.on 'connected', =>
      @battleManager.on 'battle-ready', =>
        @setStatusText 'Battle is ready!'
        @battleManager.join()
      @battleManager.on 'battle-status', (status)=> @onBattleStatus(status)
      @battleManager.on 'player-connected', (userId) =>
        @setStatusText 'Joined battle ' + @battleManager.model.battle.connectedPlayers.length + ' players connected.'
      @battleManager.on 'player-disconnected', (userId) =>
        @setStatusText 'Joined battle ' + @battleManager.model.battle.connectedPlayers.length + ' players connected.'
      @battleManager.on 'joined', (battle) =>
        @setStatusText 'Joined battle ' + battle.battle.connectedPlayers.length + ' players connected.'

    @deactivate: ->
      @myStage.removeChild @
