define ['gfx/icon', 'gfx/styles', 'util', 'pixi', 'tween'], (Icon, STYLES, Util) ->
  ICON_TEXTURE = '/media/images/icons/health.png'

  class HealthIcon extends Icon
    constructor: (health) ->
      super(health.toString(), ICON_TEXTURE)

    setHealth:(health) ->
      @setText(health.toString())
