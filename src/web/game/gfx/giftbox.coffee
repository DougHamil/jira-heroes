define ['emitters', 'gfx/wallet', 'gfx/glyphtext', 'battle/animation', 'engine', 'gfx/styles', 'util', 'pixi', 'tween'], (Emitters, Wallet, GlyphText, Animation, engine, styles, Util) ->
  GIFTBOX_BOTTOM_TEXTURE = PIXI.Texture.fromImage '/media/images/icons/giftbox_bottom.png'
  GIFTBOX_LID_TEXTURE = PIXI.Texture.fromImage 'media/images/icons/giftbox_lid.png'
  CONFETTI_TEXTURE = PIXI.Texture.fromImage 'media/images/fx/square_small.png'

  WIDTH = 256
  HEIGHT = 256
  TINTS = [0x22B222]
  ORIGIN = {x:-500, y:engine.HEIGHT/2}

  class GiftBox extends PIXI.DisplayObjectContainer
    constructor: (@gift) ->
      super
      @width = WIDTH
      @height = HEIGHT
      tint = TINTS[Math.floor(Math.random() * TINTS.length)]
      @heading = new PIXI.Text "You've received a gift from #{gift.fromName}!", styles.TEXT
      @heading.anchor = {x:0.5, y:0}
      @heading.position = {x:0, y:150}
      @bottomSprite = new PIXI.Sprite GIFTBOX_BOTTOM_TEXTURE
      @bottomSprite.width = @width
      @bottomSprite.height = @height
      @bottomSprite.position = {x:-@bottomSprite.width/2, y:-@bottomSprite.height/2}
      @bottomSprite.tint = tint
      @lidSprite = new PIXI.Sprite GIFTBOX_LID_TEXTURE
      @lidSprite.width = @width
      @lidSprite.height = @height
      @lidSprite.anchor = {x:0.5, y:0.5}
      @lidSprite.position = {x:0, y:0}
      @lidSprite.tint = tint
      @cont = new PIXI.DisplayObjectContainer()
      @cont.addChild @bottomSprite
      @cont.addChild @lidSprite
      @cont.addChild @heading
      @.addChild @cont
      @giftWallet = new Wallet @gift.gift
      @giftWallet.anchor = {x:0, y:0}
      @giftWallet.position = {x:-@giftWallet.width/2, y:-240}
      @giftWallet.visible = false
      @coins = []
      if @gift.gift.storyPoints?
        for i in [0...parseInt(@gift.gift.storyPoints)]
          @coins.push new GlyphText('<storypoint>')
      if @gift.gift.bugsReported?
        for i in [0...parseInt(@gift.gift.bugsReported)]
          @coins.push new GlyphText('<bugsreported>')
      if @gift.gift.bugsClosed?
        for i in [0...parseInt(@gift.gift.bugsClosed)]
          @coins.push new GlyphText('<bugsclosed>')
      for coin in @coins
        @cont.addChild coin
      @cont.addChild @bottomSprite
      @cont.addChild @lidSprite
      @cont.addChild @heading
      @cont.addChild @giftWallet
      @cont.hitArea = new PIXI.Rectangle(-@width/2, -@height/2, @width, @height)
      @cont.interactive = true
      @cont.click = =>
        @_animateOpen().play()
        @cont.click = null

    animate: ->
      animation = new Animation()
      animation.addTweenStep =>
        cont = @cont
        tween = new TWEEN.Tween(Util.clone(ORIGIN)).to({x:engine.WIDTH/2, y:engine.HEIGHT/2})
        tween.easing(TWEEN.Easing.Elastic.Out)
        tween.onUpdate ->
          cont.position.x = @x
          cont.position.y = @y
        return tween
      return animation

    _animateOpen: ->
      lid = @lidSprite
      emitter = Emitters.SpriteFountain
        texture:CONFETTI_TEXTURE
        life:[0.5,1.0]
        tint:'random'
        vel0:10
        vel1:15
        rate:10
        angle:40
        gravity:25
      emitter.p.x = @cont.position.x
      emitter.p.y = @cont.position.y
      animation = new Animation()
      animation.addTweenStep =>
        sPos = Util.clone(lid.position)
        sPos.rot = 0
        tPos = Util.clone(lid.position)
        tPos.y -= 40
        tPos.rot = Math.PI
        lid.pivot = {x:0.5, y:0.5}
        lid.anchor = {x:0.5, y:0.5}
        tween = new TWEEN.Tween(Util.clone(lid.position)).to(tPos, 500)
        tween.onUpdate ->
          lid.position.x = @x
          lid.position.y = @y
          lid.rotation = (Math.PI / 16) * Math.sin(@rot)
        return tween
      animation.addTweenStep =>
        sPos = Util.clone(lid.position)
        sPos.rot = 0
        tPos = Util.clone(lid.position)
        tPos.x = -100
        tPos.rot = -Math.PI / 4
        tween = new TWEEN.Tween(sPos).to(tPos, 1000)
        tween.easing(TWEEN.Easing.Cubic.Out)
        tween.onUpdate ->
          lid.position.x = @x
          lid.position.y = @y
          lid.rotation = @rot
        return tween
      animation.addAnimationStep =>
        emitter.emit()
        return new Animation()
      animation.addTweenStep =>
        _tweenCoin = (c) ->
          sPos = Util.clone(c.position)
          tPos = Util.clone(c.position)
          tPos.x = (Math.random() - 0.5) * 500
          tPos.y = -200
          tween = new TWEEN.Tween(sPos).to(tPos, 800).easing(TWEEN.Easing.Cubic.Out)
          tween.onUpdate ->
            c.position.x = @x
            c.position.y = @y
          return tween
        tweens = []
        for coin in @coins
          tweens.push _tweenCoin(coin)
        @giftWallet.visible = true
        return tweens
      animation.addPauseStep 1000, 'pause1'
      animation.addPauseStep 1000
      animation.on 'complete-step-pause1', =>
        emitter.stopEmit()
      animation.on 'complete', =>
        @openCallback?(@gift)
      return animation

    onOpened: (@openCallback) ->
