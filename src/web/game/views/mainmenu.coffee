define ['jiraheroes', 'engine', 'gui', 'pixi'], (JH, engine, GUI) ->
  BACKGROUND_TEXTURE = PIXI.Texture.fromImage '/media/images/background.png'
  LOGO_TEXTURE = PIXI.Texture.fromImage '/media/images/logo.png'
  LOGOUT_TEXTURE = PIXI.Texture.fromImage '/media/images/icons/logout.png'
  GIFT_ICON_TEXTURE = PIXI.Texture.fromImage '/media/images/icons/gift.png'

  class MainMenu extends PIXI.DisplayObjectContainer
    constructor: (@manager, stage) ->
      super
      @myStage = stage
      @myStage.addChild new PIXI.Sprite BACKGROUND_TEXTURE
      @lineLayer = new PIXI.DisplayObjectContainer()
      @myStage.addChild @lineLayer
      # Return cursor to arrow:
      @myStage.buttonMode = true
      @myStage.interactive = true
      @myStage.defaultCursor = 'inherit'
      for i in [0...10]
        line = new GUI.Scanline()
        @lineLayer.addChild line
      for i in [0...5]
        line = new GUI.Scanline(true)
        @lineLayer.addChild line

      rotLines = =>
        newRot = (Math.random() - 0.5) * 50
        layer = @lineLayer
        tween = new TWEEN.Tween({rot:@lineLayer.position.y}).to({rot:newRot}, 500).easing(TWEEN.Easing.Elastic.Out)
        tween.onUpdate ->
          layer.position = {x:0, y:@rot}
        tween.start()
        tween = new TWEEN.Tween({pos:@logoSprite.position.x}).to({pos:@logoSprite.position.x + newRot}, 500).easing(TWEEN.Easing.Elastic.Out)
        logo = @logoSprite
        origPos = @logoSprite.position.x
        tween.onUpdate ->
          logo.position = {x:@pos, y:logo.position.y}
        tween.onComplete =>
          tween2 = new TWEEN.Tween({pos:@logoSprite.position.x}).to({pos:origPos}).easing(TWEEN.Easing.Elastic.Out)
          tween2.onUpdate ->
            logo.position = {x:@pos, y:logo.position.y}
          tween2.start()
        tween.start()
      setInterval rotLines, 5000
      @playBotBtn = new GUI.TextButton 'Play Bot'
      @hostBtn = new GUI.TextButton 'Host Battle'
      @joinBtn = new GUI.TextButton 'Join Battle'
      @decksBtn = new GUI.TextButton 'Decks'
      @storeBtn = new GUI.TextButton 'Store'
      @logoutBtn = new GUI.SpriteButton LOGOUT_TEXTURE
      @giftBtn = new GUI.SpriteButton GIFT_ICON_TEXTURE
      @logoSprite = new PIXI.Sprite LOGO_TEXTURE
      @playBotBtn.position = {x:(engine.WIDTH/2) - @playBotBtn.width/2, y:(engine.HEIGHT/2) - 2 * @playBotBtn.height}
      @hostBtn.position = {x:(engine.WIDTH/2) - @hostBtn.width/2, y:(engine.HEIGHT/2)}
      @joinBtn.position = {x:(engine.WIDTH/2) - @joinBtn.width/2, y:@hostBtn.position.y + 2 * @joinBtn.height}
      @decksBtn.position = {x:(engine.WIDTH/2) - @decksBtn.width/2, y:@joinBtn.position.y + 2 * @decksBtn.height}
      @storeBtn.position = {x:(engine.WIDTH/2) - @storeBtn.width/2, y:@decksBtn.position.y + 2 * @storeBtn.height}
      @logoutBtn.position = {x:20, y:engine.HEIGHT - @logoutBtn.height - 20}
      @giftBtn.position = {x:engine.WIDTH - @giftBtn.width - 20, y:engine.HEIGHT - @giftBtn.height - 50}

      @storeBtn.onClick => @manager.activateView 'Store'
      @decksBtn.onClick => @manager.activateView 'Decks'
      @hostBtn.onClick => @manager.activateView 'HostBattle', false
      @playBotBtn.onClick => @manager.activateView 'HostBattle', true
      @joinBtn.onClick => @manager.activateView 'JoinBattle'
      @giftBtn.onClick => @manager.activateView 'Gift', @gifts
      @logoutBtn.onClick => window.location = 'user/logout'

      @.addChild @logoSprite
      @.addChild @hostBtn
      @.addChild @playBotBtn
      @.addChild @joinBtn
      @.addChild @decksBtn
      @.addChild @storeBtn
      @.addChild @logoutBtn
      @.addChild @giftBtn

    onActiveBattlePicked: (battleId) ->
      JH.GetBattle battleId, (battle) =>
        @manager.activateView 'Battle', battle

    deactivate: ->
      @myStage.removeChild @
      @myStage.removeChild engine.fxLayer
      if JH.walletGraphic?
        @.removeChild JH.walletGraphic
      if JH.nameText?
        @.removeChild JH.nameText
      if @activeBattlePicker?
        @.removeChild @activeBattlePicker
        @activeBattlePicker = null

    activate: ->
      activate = (battles, user, usersById, @gifts) =>
        JH.user = user
        @myStage.addChild @
        @myStage.addChild engine.fxLayer
        JH.nameText = new PIXI.Text "#{user.name}", GUI.STYLES.TEXT
        JH.nameText.position = {x: engine.WIDTH - JH.nameText.width, y:0}
        if not JH.walletGraphic?
          JH.walletGraphic = new GUI.Wallet user.wallet
        else
          JH.walletGraphic.update(user.wallet)
        JH.walletGraphic.position = {x: engine.WIDTH - JH.walletGraphic.width - 20, y: engine.HEIGHT - JH.walletGraphic.height - 20}
        @.addChild JH.walletGraphic
        @.addChild JH.nameText
        if battles? and battles.length > 0
          @activeBattlePicker = new GUI.BattlePicker battles, usersById
          @activeBattlePicker.onBattlePicked (battleId) => @onActiveBattlePicked(battleId)
          @activeBattlePicker.position = {x:0, y:260}
          @.addChild @activeBattlePicker
      JH.GetUser (user) =>
        JH.GetGifts (gifts) =>
          JH.GetActiveBattles (battles) =>
            userIds = battles.map (b) -> b.users[0]
            JH.GetUsers userIds, (users) =>
              usersById = {}
              for userObj in users
                usersById[userObj._id] = userObj
              JH.users = usersById
              activate battles, user, usersById, gifts
