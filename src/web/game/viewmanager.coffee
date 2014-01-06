define ['./views/mainmenu',
        './views/campaign',
        './views/campaignmenu',
        './views/library',
        './views/decks',
        'jiraheroes', 'engine'], (MainMenu, Campaign, CampaignMenu, Library, Decks, JH) ->
  class MenuManager
    constructor: (@stage) ->
      @views =
        'MainMenu': new MainMenu @, @stage
        'Library': new Library @, @stage
        'Campaign': new Campaign @, @stage
        'CampaignMenu': new CampaignMenu @, @stage
        'Decks': new Decks @, @stage

    activateView: (view, args...) ->
      if @activeView?
        console.log 'Deactivating '+@activeView
        @activeView.deactivate()
      console.log 'Activating '+view
      @views[view].activate(args...)
      @activeView = @views[view]
