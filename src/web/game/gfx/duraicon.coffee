define ['gfx/icon', 'gfx/styles', 'util', 'pixi', 'tween'], (Icon, STYLES, Util) ->
  ICON_TEXTURE = '/media/images/icons/dura.png'

  class DuraIcon extends Icon
    constructor: (dura, @default) ->
      super(dura.toString(), ICON_TEXTURE)
      @setDurability(dura)

    setDurability:(dura) ->
      @dura = dura
      @setText(dura.toString())
      if dura > @default
        @setStyle STYLES.ICON_TEXT_GOOD
      else if dura < @default
        @setStyle STYLES.ICON_TEXT_BAD
      else
        @setStyle STYLES.ICON_TEXT_NORMAL

    setDefault:(@default) ->
