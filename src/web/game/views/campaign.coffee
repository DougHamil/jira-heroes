define ['gfx/campaignmap', 'client/gamemanager', 'jiraheroes', 'gui', 'engine', 'pixi', 'tween'], (CampaignMap, GameManager, JH, GUI, engine) ->
  class Campaign extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super

    deactivate: ->
      @myStage.removeChild @
      @.removeChild @heading
      @gameManager.disconnect()

    activate: (@hero, @campaign) ->
      @heading = new PIXI.Text "#{@hero.name} in #{@campaign.name}", GUI.STYLES.HEADING
      @.addChild @heading
      @myStage.addChild @
      @gameManager = new GameManager @hero, @campaign
      @gameManager.on 'disconnect', =>
        alert 'Disconnected from game server'
        @manager.activateView 'HeroMenu'
      @gameManager.on 'joined', (campaignData) => @onCampaignJoined(campaignData)
      @gameManager.socket.on 'heroMoved', (heroId, node) =>
        @map.moveHero heroId, node
      @gameManager.socket.on 'heroJoined', (hero, node) =>
        @map.addHero hero, node


    onCampaignJoined: (data) ->
      console.log "Joined campaign"
      @map = new CampaignMap data
      @map.on 'nodeClicked', (node) =>
        console.log "Node clicked: #{node}"
        @gameManager.moveTo node, (data) =>
          if data? and data.error?
            console.log err
          else
            console.log data
            @map.moveHero @hero._id, node
      @.addChild @map

