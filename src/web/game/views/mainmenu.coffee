define ['jiraheroes', 'engine', 'gui', 'pixi'], (JH, engine, GUI) ->

  class MainMenu extends PIXI.DisplayObjectContainer
    constructor: (@manager, stage) ->
      super
      @myStage = stage
      @menuText = new PIXI.Text 'JIRA Heroes', GUI.STYLES.HEADING
      @hostBtn = new GUI.TextButton 'Host Battle'
      @joinBtn = new GUI.TextButton 'Join Battle'
      @decksBtn = new GUI.TextButton 'Decks'
      @libraryBtn = new GUI.TextButton 'Library'
      @hostBtn.position = {x:(engine.WIDTH/2) - @hostBtn.width/2, y:(engine.HEIGHT/2)}
      @joinBtn.position = {x:(engine.WIDTH/2) - @joinBtn.width/2, y:@hostBtn.position.y + 2 * @joinBtn.height}
      @decksBtn.position = {x:(engine.WIDTH/2) - @decksBtn.width/2, y:@joinBtn.position.y + 2 * @decksBtn.height}
      @libraryBtn.position = {x:(engine.WIDTH/2) - @libraryBtn.width/2, y:@decksBtn.position.y + 2 * @libraryBtn.height}

      @libraryBtn.onClick => @manager.activateView 'Library'
      @decksBtn.onClick => @manager.activateView 'Decks'
      @hostBtn.onClick => @manager.activateView 'HostBattle'
      @joinBtn.onClick => @manager.activateView 'JoinBattle'

      @.addChild @menuText
      @.addChild @hostBtn
      @.addChild @joinBtn
      @.addChild @decksBtn
      @.addChild @libraryBtn

    onActiveBattlePicked: (battleId) ->
      JH.GetBattle battleId, (battle) =>
        @manager.activateView 'Battle', battle

    deactivate: ->
      @myStage.removeChild @
      if JH.pointsText?
        @.removeChild JH.pointsText
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
        JH.pointsText = new GUI.GlyphText "#{user.points} <coin>"
        JH.pointsText.position = {x: engine.WIDTH - JH.pointsText.width - 20, y: engine.HEIGHT - JH.pointsText.height - 20}
        @.addChild JH.pointsText
        @.addChild JH.nameText
        if battles? and battles.length > 0
          @activeBattlePicker = new GUI.BattlePicker battles, usersById
          @activeBattlePicker.onBattlePicked (battleId) => @onActiveBattlePicked(battleId)
          @activeBattlePicker.position = {x:0, y:100}
          @.addChild @activeBattlePicker
      JH.GetUser (user) =>
        JH.GetActiveBattles (battles) =>
          userIds = battles.map (b) -> b.users[0]
          JH.GetUsers userIds, (users) =>
            usersById = {}
            for user in users
              usersById[user._id] = user
            activate battles, user, usersById
