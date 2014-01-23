define ['jquery', 'jiraheroes', 'gui', 'battle/cardanimator', 'client/battlemanager', 'engine', 'pixi'], ($, JH, GUI, CardAnimator, BattleManager, engine) ->
  BACKDROP_TEXTURE = PIXI.Texture.fromImage '/media/images/backdrop.png'
  ###
  # This view displays the actual battle part of the game to the player
  ###
  class Battle extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @backdropImage = new PIXI.Sprite BACKDROP_TEXTURE
      @statusText = new PIXI.Text 'Hosting battle...', GUI.STYLES.TEXT
      @winBattleText = new PIXI.Text 'You won!', GUI.STYLES.HEADING
      @loseBattleText = new PIXI.Text 'You lost', GUI.STYLES.HEADING
      @winBattleText.position = {x: engine.WIDTH/2 - @winBattleText.width/2, y:engine.HEIGHT/2 - @winBattleText.height/2}
      @loseBattleText.position = {x: engine.WIDTH/2 - @loseBattleText.width/2, y:engine.HEIGHT/2 - @loseBattleText.height/2}
      @setStatusText 'Connecting to battle...'

      # UI Layer is always above GFX layer
      @uiLayer = new PIXI.DisplayObjectContainer()
      @gfxLayer = new PIXI.DisplayObjectContainer()
      @.addChild @backdropImage
      @.addChild @gfxLayer
      @.addChild @uiLayer
      @uiLayer.addChild @statusText

    setStatusText: (text) ->
      @statusText.setText text

    initUI: (phase) ->
      if @innerStage?
        @.removeChild @innerStage
      @innerStage = new PIXI.DisplayObjectContainer
      if phase is 'game'
        @endTurnButton = new GUI.EndTurnButton()
        @endTurnButton.position = {x: engine.WIDTH - 20 - @endTurnButton.width, y: engine.HEIGHT/2 - @endTurnButton.height/2}
        @endTurnButton.onClick => @battle.emitEndTurnEvent()

        @energySprite = new PIXI.Text @battle.getEnergy() + " energy",  GUI.STYLES.TEXT
        @energySprite.position = {x:engine.WIDTH - 20 - @energySprite.width, y: 20}
        @cardAnimator = new CardAnimator(JH.heroes, JH.cards, JH.user._id, @battle)
        @uiLayer.addChild @energySprite
        @gfxLayer.addChild @cardAnimator
        @uiLayer.addChild @endTurnButton

        @battle.on 'action-win-battle', (action) =>
          if action.player is JH.user._id
            @.removeChild @gfxLayer
            @.removeChild @backdropImage
            @uiLayer.addChild @winBattleText
        @battle.on 'action-lose-battle', (action) =>
          if action.player is JH.user._id
            @.removeChild @gfxLayer
            @.removeChild @backdropImage
            @uiLayer.addChild @loseBattleText

      @.addChild @innerStage

    updateEnergy: ->
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
      @battle.on 'your-turn', => @setYourTurn(true)
      @battle.on 'opponent-turn', => @setYourTurn(false)
      @battle.on 'phase', (o, n) => @initUI(n)
      @battle.on 'action-energy', => @updateEnergy()
      @battle.on 'action-max-energy', => @updateEnergy()
      updateStatus()
      @initUI @battle.getPhase()
      @updateEnergy()
      @setYourTurn(@battle.isYourTurn())

    setYourTurn: (isYourTurn) ->
      if isYourTurn
        @setStatusText("It's your turn!")
      else
        @setStatusText("Opponent's turn")

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
      if @cardAnimator?
        @.removeChild @cardAnimator
        @cardAnimator = null
