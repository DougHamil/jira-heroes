define ['./styles', 'util', 'engine', 'pixi', 'tween'], (styles, Util, engine) ->
  WIDTH = 300
  HEIGHT = 100

  class CampaignButton extends PIXI.DisplayObjectContainer
    constructor: (campaignModel) ->
      super
      console.log campaignModel
      @name = new PIXI.Text campaignModel.name, styles.TEXT
      @class = new PIXI.Text campaignModel.class.name, styles.TEXT
      #TODO Add sprite icon for campaignModel class
      @bg = new PIXI.Graphics()
      @bg.beginFill styles.BUTTON_COLOR
      @bg.drawRect(0, 0, WIDTH, HEIGHT)
      @class.position = {x:10, y:@name.height + 5}
      @cont = new PIXI.DisplayObjectContainer()
      @cont.addChild @bg
      @cont.addChild @name
      @cont.addChild @class
      @cont.hitArea = new PIXI.Rectangle 0, 0, WIDTH, HEIGHT
      @.height = HEIGHT
      @.width = WIDTH
      @.addChild @cont
      @.interactive = true

      to = {x:20, y:0}
      from = {x:0, y:0}
      time = 250
      @tweens =
        out: Util.spriteTween(@cont, from, to, time).easing(TWEEN.Easing.Cubic.Out)
        in: Util.spriteTween(@cont, to, from, time).easing(TWEEN.Easing.Cubic.Out)
      @.mouseover = =>
        @animate 'out'
      @.mouseout = =>
        @animate 'in'

    onClick: (callback) ->
      @.click = =>
        callback @

    animate: (animation) ->
      if animation == 'none'
        return
      @activeTween = @tweens[animation]
      @tweens[animation].start()
  return CampaignButton
