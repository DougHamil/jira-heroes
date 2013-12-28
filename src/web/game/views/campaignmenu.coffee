define ['jquery', 'jiraheroes', 'gui', 'engine', 'gfx/styles','pixi'], ($, JH, GUI, engine) ->
  class CampaignMenu extends PIXI.DisplayObjectContainer
    constructor: (@manager, stage) ->
      super
      @myStage = stage
      @heading = new PIXI.Text 'Join a Campaign', GUI.STYLES.HEADING
      @nameField = new GUI.TextField {x:engine.WIDTH/2, y:engine.HEIGHT/2}
      @newBtn = new GUI.TextButton 'New'
      @backBtn = new GUI.TextButton 'Back'
      @backBtn.position = {x:engine.WIDTH - @backBtn.width, y:0}
      @backBtn.onClick =>
        @manager.activateView 'HeroMenu'
      @newBtn.onClick =>
        @createNewCampaign()
      @.addChild @heading
      @.addChild @backBtn
      @.addChild @newBtn
      @newBtn.position = {x:engine.WIDTH/2 + @nameField.width() + 5, y:engine.HEIGHT/2}
      @nameField.hide()

    createNewCampaign: ->
      campaignName = @nameField.getValue()
      if campaignName? and campaignName != ''
        JH.CreateCampaign campaignName, 'test', (data) =>
          console.log "Created new campaign: #{data}"
          JH.JoinCampaign @hero._id, data, (data) =>
            console.log "Joined new campaign: #{data}"
            @manager.activateView 'Campaign', @hero, data

    joinCampaign: (campaign) ->
      JH.JoinCampaign @hero._id, campaign._id, (data) =>
        @manager.activateView 'Campaign', @hero, data

    deactivate: ->
      @nameField.hide()
      @myStage.removeChild @
      for btn in @buttons
        @.removeChild btn

    activate: (@hero) ->
      @nameField.show()
      @myStage.addChild @
      JH.GetOpenCampaigns (campaigns) =>
        x = 0
        y = 50
        @buttons = []
        btnHandler = (campaign) =>
          return =>
            @joinCampaign campaign
        for campaign in campaigns
          btn = new GUI.CampaignButton campaign
          btn.position = {x:x, y:y}
          btn.onClick btnHandler(campaign)
          y += btn.height
          @buttons.push btn
          @.addChild btn
