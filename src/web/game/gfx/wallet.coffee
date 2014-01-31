define ['gfx/styles', 'gfx/glyphtext', 'util', 'pixi', 'tween'], (styles, GlyphText, Util) ->
  class Wallet extends PIXI.DisplayObjectContainer
    constructor: (wallet) ->
      super
      @update(wallet)
      @width = @text.width
      @height = @text.height

    update: (wallet) ->
      @.removeChild @text if @text?
      @text = new GlyphText "#{wallet.storyPoints} <storypoint> #{wallet.bugsReported} <bugsreported> #{wallet.bugsClosed} <bugsclosed>"
      @.addChild @text

