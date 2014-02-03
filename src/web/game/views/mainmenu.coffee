define ['jiraheroes', 'engine', 'gui', 'pixi'], (JH, engine, GUI) ->
  BACKGROUND_TEXTURE = PIXI.Texture.fromImage '/media/images/background.png'
  LOGO_TEXTURE = PIXI.Texture.fromImage '/media/images/logo.png'
  LOGOUT_TEXTURE = PIXI.Texture.fromImage '/media/images/icons/logout.png'

  class MainMenu extends PIXI.DisplayObjectContainer
    constructor: (@manager, stage) ->
      super
      @myStage = stage
      @myStage.addChild new PIXI.Sprite BACKGROUND_TEXTURE
      @playBotBtn = new GUI.TextButton 'Play Bot'
      @hostBtn = new GUI.TextButton 'Host Battle'
      @joinBtn = new GUI.TextButton 'Join Battle'
      @decksBtn = new GUI.TextButton 'Decks'
      @libraryBtn = new GUI.TextButton 'Library'
      @logoutBtn = new GUI.SpriteButton LOGOUT_TEXTURE
      @logoSprite = new PIXI.Sprite LOGO_TEXTURE
      @playBotBtn.position = {x:(engine.WIDTH/2) - @playBotBtn.width/2, y:(engine.HEIGHT/2) - 2 * @playBotBtn.height}
      @hostBtn.position = {x:(engine.WIDTH/2) - @hostBtn.width/2, y:(engine.HEIGHT/2)}
      @joinBtn.position = {x:(engine.WIDTH/2) - @joinBtn.width/2, y:@hostBtn.position.y + 2 * @joinBtn.height}
      @decksBtn.position = {x:(engine.WIDTH/2) - @decksBtn.width/2, y:@joinBtn.position.y + 2 * @decksBtn.height}
      @libraryBtn.position = {x:(engine.WIDTH/2) - @libraryBtn.width/2, y:@decksBtn.position.y + 2 * @libraryBtn.height}
      @logoutBtn.position = {x:20, y:engine.HEIGHT - @logoutBtn.height - 20}

      @libraryBtn.onClick => @manager.activateView 'Library'
      @decksBtn.onClick => @manager.activateView 'Decks'
      @hostBtn.onClick => @manager.activateView 'HostBattle', false
      @playBotBtn.onClick => @manager.activateView 'HostBattle', true
      @joinBtn.onClick => @manager.activateView 'JoinBattle'
      @logoutBtn.onClick => window.location = 'user/logout'

      @.addChild @logoSprite
      @.addChild @hostBtn
      @.addChild @playBotBtn
      @.addChild @joinBtn
      @.addChild @decksBtn
      @.addChild @libraryBtn
      @.addChild @logoutBtn

    onActiveBattlePicked: (battleId) ->
      JH.GetBattle battleId, (battle) =>
        @manager.activateView 'Battle', battle

    deactivate: ->
      @myStage.removeChild @
      if JH.walletGraphic?
        @.removeChild JH.walletGraphic
      if JH.nameText?
        @.removeChild JH.nameText
      if @activeBattlePicker?
        @.removeChild @activeBattlePicker
        @activeBattlePicker = null

    activate: ->
      activate = (battles, user, usersById) =>
        JH.user = user
        @myStage.addChild @
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
        JH.GetActiveBattles (battles) =>
          userIds = battles.map (b) -> b.users[0]
          JH.GetUsers userIds, (users) =>
            usersById = {}
            for userObj in users
              usersById[userObj._id] = userObj
            activate battles, user, usersById
