define ['jiraheroes', 'engine', 'gui', 'pixi'], (JH, engine, GUI) ->

  BACKGROUND_TEXTURE = PIXI.Texture.fromImage '/media/images/backgrounds/heromenu.png'

  class HeroMenu extends PIXI.DisplayObjectContainer
    constructor: (@manager, stage) ->
      super
      @myStage = stage
      @bgSprite = new PIXI.Sprite BACKGROUND_TEXTURE
      @menuText = new PIXI.Text 'Select a Hero', GUI.STYLES.HEADING
      @newBtn = new GUI.TextButton 'New'
      @newBtn.position = {x:(engine.WIDTH/2), y:(engine.HEIGHT/2) + 2 * @newBtn.height}
      @newBtn.onClick =>
        @manager.activateView 'CreateHeroMenu'
      #@.addChild @bgSprite
      @.addChild @menuText
      @.addChild @newBtn

    deactivate: ->
      @myStage.removeChild @
      for btn in @heroButtons
        @.removeChild btn

    onHeroClicked: (hero) ->
      if hero.campaign?
        JH.GetCampaign hero.campaign, (campaign) =>
          @manager.activateView 'Campaign', hero, campaign
      else
        @manager.activateView 'CampaignMenu', hero

    activate: ->
      @myStage.addChild @
      JH.GetHeroes (heroes) =>
        x = 50
        y = 100
        @heroButtons = []
        heroButtonHandler = (hero) =>
          return =>
            @onHeroClicked(hero)
        for hero in heroes
          btn = new GUI.HeroButton hero
          btn.position.x = x
          btn.position.y = y
          x = x + 350
          @.addChild btn
          btn.onClick heroButtonHandler(hero)
          @heroButtons.push btn
