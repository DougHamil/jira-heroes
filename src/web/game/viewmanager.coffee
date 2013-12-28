define ['./views/heromenu',
        './views/createhero',
        './views/campaign',
        './views/campaignmenu',
        'engine'], (HeroMenu, CreateHeroMenu, Campaign, CampaignMenu) ->
  class MenuManager
    constructor: (@stage) ->
      @views =
        'HeroMenu': new HeroMenu @, @stage
        'CreateHeroMenu': new CreateHeroMenu @, @stage
        'Campaign': new Campaign @, @stage
        'CampaignMenu': new CampaignMenu @, @stage

    activateView: (view, args...) ->
      if @activeView?
        console.log 'Deactivating '+@activeView
        @activeView.deactivate()
      console.log 'Activating '+view
      @views[view].activate(args...)
      @activeView = @views[view]



