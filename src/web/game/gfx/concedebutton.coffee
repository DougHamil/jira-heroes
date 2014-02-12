define ['gfx/pulltab', 'gfx/styles', 'util', 'engine', 'pixi', 'tween'], (PullTab, STYLES, Util, engine) ->
  TINT = 0xB22222

  class ConcedeButton extends PullTab
    constructor: () ->
      super("Concede", "", "Are you sure?", TINT, TINT)
