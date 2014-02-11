define ['util', 'engine', 'eventemitter', 'battlehelpers', 'pixi'], (Util, engine, EventEmitter) ->
  ###
  # Handles changes to the battle's state
  ###
  class Battle extends EventEmitter
    constructor:(@userId, @model, @socket) ->
      super
      @cardsById = {}
      for card in @model.you.hand
        @cardsById[card._id] = card
        BattleHelpers.addCardMethods(card)
      for card in @model.you.field
        @cardsById[card._id] = card
        BattleHelpers.addCardMethods(card)
      for opp in @model.opponents
        for card in opp.hand
          @cardsById[card] = card
        for card in opp.field
          @cardsById[card._id] = card
          BattleHelpers.addCardMethods(card)
        BattleHelpers.addHeroMethods(opp.hero)
      BattleHelpers.addHeroMethods(@model.you.hero)
      @socket.on 'player-connected', (userId) => @onPlayerConnected(userId)
      @socket.on 'player-disconnected', (userId) => @onPlayerDisconnected(userId)
      @socket.on 'your-turn', => @emit 'your-turn'
      @socket.on 'opponent-turn', (id) => @emit 'opponent-turn'
      @socket.on 'phase', (oldPhase, newPhase) => @onPhaseChanged(oldPhase, newPhase)
      @socket.on 'action', (actions) => @processAndEmit 'action', actions

    processAndEmit: (event, actions) ->
      @emit 'start-'+event, actions
      added = {} # Track cards just added in this batch of actions, because modifiers will have already been applied
      for action in actions
        @process(action, added)
      @emit event, actions

    process: (action, added) ->
      switch action.type
        when 'weapon-destroy'
          target = @getHero action.hero
          target.weapon = null
        when 'weapon-durability'
          target = @getHero action.hero
          target.weapon.durability += action.amount
        when 'weapon-equip'
          target = @getHero action.hero
          target.weapon = action.weapon
        when 'add-modifier'
          target = @getCard action.target
          if target? and added[target._id]?
            return
          if not target?
            target = @getHero action.target
          if target?
            hasMod = false
            for modifier in target.modifiers
              if modifier._id.toString() is action.modifier._id.toString()
                hasMod = true
            if not hasMod
              target.modifiers.push action.modifier
        when 'remove-modifier'
          target = @getCard action.target
          if target? and added[target._id]?
            return
          if not target?
            target = @getHero action.target
          if target?
            target.modifiers = target.modifiers.filter (m) -> m._id.toString() isnt action.modifier.toString()
        when 'status-add'
          target = @getCardOrHero action.target
          if target? and added[target._id]?
            return
          if target?
            if not target.status?
              target.status = []
            if action.status not in target.status
              target.status.push action.status
        when 'status-remove'
          target = @getCardOrHero action.target
          if target? and added[target._id]?
            return
          if target?
            if not target.status?
              target.status = []
            target.status = target.status.filter (s) -> s isnt action.status
        when 'heal'
          card = @getCard(action.target)
          if target? and added[target._id]?
            return
          if card?
            card.health += action.amount
          else
            hero = @getHero(action.target)
            if hero?
              hero.health += action.amount
        when 'overheal'
          card = @getCard(action.target)
          if target? and added[target._id]?
            return
          if card?
            card.health += action.amount
          else
            hero = @getHero(action.target)
            hero.health += action.amount if hero?
        when 'damage'
          card = @getCard(action.target)
          if target? and added[target._id]?
            return
          if card?
            card.health -= action.damage
          else
            hero = @getHero(action.target)
            if hero?
              hero.health -= action.damage
              console.log hero.health
        when 'discard-card'
          card = @getCard(action.card)
          if card?
            card.position = 'discard'
        when 'start-turn'
          @model.activePlayer = action.player
        when 'draw-card'
          if action.card._id?
            @cardsById[action.card._id] = action.card
            BattleHelpers.addCardMethods(action.card)
            added[action.card._id] = true
          @getPlayer(action.player).hand.push action.card
        when 'max-energy'
          @getPlayer(action.player).maxEnergy += action.amount
        when 'energy'
          @getPlayer(action.player).energy += action.amount
        when 'play-card'
          if action.player isnt @userId and action.card._id?
            @cardsById[action.card._id] = action.card
            BattleHelpers.addCardMethods(action.card)
            added[action.card._id] = true
          @cardsById[action.card._id].position = action.card.position
          @getPlayer(action.player).field.push action.card
        when 'cast-card'
          if action.player isnt @userId and action.card._id?
            @cardsById[action.card._id] = action.card
            BattleHelpers.addCardMethods(action.card)
            added[action.card._id] = true
          @cardsById[action.card._id].position = action.card.position
        when 'discard-card'
          @cardsById[action.card] = 'discard'
      console.log action
      @emit 'action-'+action.type, action

    onPhaseChanged:(oldPhase, newPhase) ->
      @model.state.phase = newPhase
      @emit 'phase', oldPhase, newPhase

    onPlayerConnected: (userId) ->
      @model.connectedPlayers.push userId
      @emit 'player-connected', userId

    onPlayerDisconnected: (userId) ->
      @model.connectedPlayers = @model.connectedPlayers.filter (p) -> p isnt userId
      @emit 'player-disconnected', userId

    getPlayerId: -> return @userId
    getUserId: -> return @userId
    getEnemyId: -> return @model.opponents[0].userId
    getPlayer: (id) ->
      if id is @userId
        return @model.you
      else
        for user in @model.opponents
          if user.userId is id
            return user
        return null

    getConnectedPlayers: -> return @model.connectedPlayers
    getPhase: -> return @model.state.phase
    getCardOrHero: (id) ->
      hero = @getHeroById(id)
      if hero?
        return hero
      else
        return @getCard(id)
    getCard: (id) ->
      if id._id?
        return id
      return @cardsById[id]
    getCardsInHand: -> return @model.you.hand
    getEnemyCardsInHand: ->
      cards = []
      for enemy in @model.opponents
        cards = cards.concat(enemy.hand)
      return cards
    getCardsOnField: -> return @model.you.field
    getEnemyCardsOnField: ->
      cards = []
      for enemy in @model.opponents
        cards = cards.concat(enemy.field)
      return cards
    getEnergy: -> return @model.you.energy
    getMaxEnergy: -> return @model.you.maxEnergy
    getHeroById: (heroId) ->
      if heroId._id?
        heroId = heroId._id
      if heroId is @model.you.hero._id
        return @model.you.hero
      for opp in @model.opponents
        if opp.hero._id is heroId
          return opp.hero
      return null
    getHero: (heroId) ->
      if heroId?
        return @getHeroById(heroId)
      return @getMyHero()
    getMyCards: ->
      cards = []
      for id, card of @cardsById
        if card.userId is @userId
          cards.push card
      return cards
    getMyHero: -> return @model.you.hero
    getEnemyHero: -> return @model.opponents[0].hero
    isYourTurn: -> return @model.activePlayer is @userId
    hasValidMoves: ->
      for card in @getMyCards()
        console.log card
        switch card.position
          when 'field'
            console.log card.getStatus()
            if 'used' not in card.getStatus() and 'frozen' not in card.getStatus() and 'sleeping' not in card.getStatus()
              return true
            else if 'sleeping' in card.getStatus() and 'can-rush' in card.getStatus()
              return true
          when 'hand'
            if card.getEnergy() <= @getEnergy()
              return true
      hero = @getMyHero()
      if hero.getAbilityEnergy() <= @getEnergy() and 'ability-used' not in hero.getStatus()
        return true
      if hero.getDamage() > 0 and 'used' not in hero.getStatus()
        return true
      return false

    emitEndTurnEvent: -> @socket.emit 'end-turn'
    emitPlayCardEvent: (cardId, target, cb) -> @socket.emit 'play-card', cardId, target, cb
    emitUseCardEvent: (cardId, target, cb) -> @socket.emit 'use-card', cardId, target, cb
    emitHeroAttackEvent: (target, cb) -> @socket.emit 'hero-attack', target, cb
    emitUseHeroEvent: (target, cb) -> @socket.emit 'use-hero', target, cb
