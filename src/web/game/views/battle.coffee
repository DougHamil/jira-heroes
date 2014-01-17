define ['jquery', 'jiraheroes', 'gui', 'cardmanager', 'client/battlemanager', 'engine', 'pixi'], ($, JH, GUI, CardManager, BattleManager, engine) ->
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

    initUI: (phase) ->
      if @innerStage?
        @.removeChild @innerStage
      @innerStage = new PIXI.DisplayObjectContainer
      if phase is 'initial'
        if not @battle.isReadied()
          # Show ready button
          readyBtn = new GUI.TextButton 'Ready', GUI.STYLES.TEXT
          readyBtn.position = {x:engine.WIDTH/2 - readyBtn.width/2, y: engine.HEIGHT/2 - readyBtn.height/2}
          readyBtn.onClick => @battle.emitReadyEvent (err)=>
            if not err?
              @innerStage.removeChild readyBtn
              txt = new PIXI.Text 'Waiting for opponent to ready-up', GUI.STYLES.TEXT
              txt.position = {x:engine.WIDTH/2 - txt.width/2, y: engine.HEIGHT/2 - txt.height/2}
              @innerStage.addChild txt
          @innerStage.addChild readyBtn
        else
          txt = new PIXI.Text 'Waiting for opponent to ready-up', GUI.STYLES.TEXT
          txt.position = {x:engine.WIDTH/2 - txt.width/2, y: engine.HEIGHT/2 - txt.height/2}
          @innerStage.addChild txt
      else if phase is 'game'
        @energySprite = new PIXI.Text @battle.getEnergy() + " energy"
        @energySprite.position = {x:engine.WIDTH - 20 - @energySprite.width, y: 20}
        @cardManager = new CardManager(JH.cards, JH.user._id, @battle)
        @.addChild @energySprite
        @.addChild @cardManager

      @.addChild @innerStage

    updateGameStatus: ->
      if @energySprite?
        @energySprite.setText @battle.getEnergy() + " energy"

    createCardSprite: (card) ->
      sprite = new GUI.Card JH.cards[card.class], card.damage, card.health, card.status
      return sprite

    onBattleStatus: (status) ->
      if status? and status.id is 'BATTLE_NOT_READY'
        @setStatusText 'Waiting for opponent to join...'

    onBattleJoined: (@battle) ->
      updateStatus = =>
        @setStatusText @battle.getConnectedPlayers().length + ' players connected.'
      @battle.on 'player-connected', => updateStatus()
      @battle.on 'player-disconnected', => updateStatus()
      @battle.on 'player-readied', => updateStatus()
      @battle.on 'your-turn', (e) => @updateGameStatus()
      @battle.on 'phase', (o, n) => @initUI(n)
      updateStatus()
      @initUI @battle.getPhase()

    activate: (@battle) ->
      @myStage.addChild @
      @battleManager = new BattleManager JH.user, @battle._id
      @battleManager.on 'connected', =>
      @battleManager.on 'battle-ready', =>
        @setStatusText 'Battle is ready!'
        @battleManager.join()
      @battleManager.on 'battle-status', (status)=> @onBattleStatus(status)
      @battleManager.on 'joined', (battle) => @onBattleJoined(battle)

    @deactivate: ->
      @myStage.removeChild @
      if @innerStage?
        @.removeChild @innerStage
        @innerStage = null
      if @cardManager?
        @.removeChild @cardManager
        @cardManager = null
