define ['gfx/styles', 'gfx/battlebutton', 'util', 'engine', 'pixi', 'tween'], (STYLES, BattleButton, Util, engine) ->
  HEIGHT = engine.HEIGHT - 100
  WIDTH = engine.WIDTH - engine.WIDTH / 4
  BATTLE_BUTTON_PADDING = 10

  ###
  # Provides an interface for selecting a battle
  ###
  class BattlePicker extends PIXI.DisplayObjectContainer
    constructor: (@battles, @users) ->
      super
      @battleButtons = {}
      y = 0
      onBattleButtonClicked = (battleId) => => @onBattlePickedCallback(battleId) if @onBattlePickedCallback?
      for battle in @battles
        battleBtn = new BattleButton battle, @users
        @.addChild battleBtn
        battleBtn.position = {x:0, y:y}
        battleBtn.onClick onBattleButtonClicked(battle._id)
        y += battleBtn.height + BATTLE_BUTTON_PADDING
        @battleButtons[battle._id] = battleBtn

    onBattlePicked: (@onBattlePickedCallback) ->
    setHighlight: (battleId, highlight) ->
      @battleButtons[battleId].setHighlight(highlight)
