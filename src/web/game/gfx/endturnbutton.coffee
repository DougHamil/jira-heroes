define ['gfx/pulltab', 'gfx/styles', 'util', 'engine', 'pixi', 'tween'], (PullTab, STYLES, Util, engine) ->
  YOUR_TURN_TINT = 0x3399BB
  YOUR_TURN_NO_OPTIONS_TINT = 0x22B222
  ENEMY_TURN_TINT = 0xBBBBBB

  class EndTurnButton extends PullTab
    constructor: (isYourTurn) ->
      super("Your Turn", "Enemy Turn", "End Turn", YOUR_TURN_TINT, ENEMY_TURN_TINT)

    setNoMoreMoves:(noMoreMoves) ->
      if noMoreMoves
        @setTint(YOUR_TURN_NO_OPTIONS_TINT)

    setIsYourTurn: (isYourTurn) ->
      @setActive(isYourTurn)
