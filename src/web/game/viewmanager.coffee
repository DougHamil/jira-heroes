define ['./views/mainmenu',
        './views/createhero',
        './views/campaign',
        './views/campaignmenu',
        './views/library',
        'engine'], (MainMenu, CreateHeroMenu, Campaign, CampaignMenu, Library) ->
  class MenuManager
    constructor: (@stage) ->
      @views =
        'MainMenu': new MainMenu @, @stage
        'Library': new Library @, @stage
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



