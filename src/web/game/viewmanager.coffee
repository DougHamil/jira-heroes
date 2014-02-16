define ['./views/mainmenu',
        './views/store',
        './views/decks',
        './views/createdeck',
        './views/editdeck',
        './views/hostbattle',
        './views/joinbattle',
        './views/battle',
        './views/gift',
        'jiraheroes', 'engine'], (
          MainMenu,
          Store,
          Decks,
          CreateDeck,
          EditDeck,
          HostBattle,
          JoinBattle,
          Battle,
          Gift,
          JH) ->
  class MenuManager
    constructor: (@stage) ->
      @views =
        'MainMenu': new MainMenu @, @stage
        'Store': new Store @, @stage
        'Decks': new Decks @, @stage
        'CreateDeck': new CreateDeck @, @stage
        'EditDeck': new EditDeck @, @stage
        'HostBattle': new HostBattle @, @stage
        'JoinBattle': new JoinBattle @, @stage
        'Battle': new Battle @, @stage
        'Gift': new Gift @, @stage

    activateView: (view, args...) ->
      if @activeView?
        @activeView.deactivate()
      @views[view].activate(args...)
      @activeView = @views[view]
