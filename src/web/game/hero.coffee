define ['pixi'], () ->
  class Hero
    constructor: (stage, data) ->
      @initGraphics(data)

    initGraphics: (data)->
      @head = new createjs.Shape()
      @body = new createjs.Container()
      bodyshape = new createjs.Shape()
      @lefthand = new createjs.Shape()
      @righthand = new createjs.Shape()

      @head.graphics.beginFill(data.skincolor).drawCircle(0, 0, 16)
      bodyshape.graphics.beginFill(data.shirtcolor).drawRoundRect(0, 0, 30, 50, 10)
      @lefthand.graphics.beginFill(data.skincolor).drawCircle(0, 0, 10)
      @righthand.graphics.beginFill(data.skincolor).drawCircle(0, 0, 10)
      bodyshape.regX = 15
      bodyshape.regy = 25
      @head.y = -8
      @body.addChild(bodyshape)
      @body.addChild(@head, @lefthand, @righthand)
      @addChild(@body)
      @body.x = 100
      @body.y = 100

