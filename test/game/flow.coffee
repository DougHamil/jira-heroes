should = require 'should'
CardCache = require '../../lib/models/cardcache'

doneCount = (done, count) ->
  num = 0
  ->
    num++
    if num is count
      done()

exports.run = (harness) ->
  describe 'GameFlow', ->
    it 'should allow the first player to play a card', (done) ->
      socket = harness.getActiveSocket()
      cards = harness.getDrawnCards harness.getActiveUser()

      harness.expectInactive 'opponent-play-card', (data) ->
        data = data[harness.getInactiveUsers()[0]]
        should.exist(data)
        userId = data[0]
        card = data[1]
        userId.should.eql harness.getActiveUser()
        card._id.should.eql(cards[0]._id)

      socket.emit 'test', 'energy', 1000, ->
        socket.emit 'play-card', cards[0]._id, null, (err, card)->
          should.not.exist(err)
          should.exist(card)
          harness.updateCard harness.getActiveUser(), card
          CardCache.get card.class, (err, cardClass) ->
            should.not.exist(err)
            status = card.status
            if 'rush' not in cardClass.traits
              status.should.contain 'sleeping'
            done()

    it 'should not allow the inactive player to end the turn', (done) ->
      inactiveSocket = harness.getSocketForUser(harness.getInactiveUsers()[0])
      inactiveSocket.emit 'end-turn', (err) ->
        should.exist(err)
        done()

    it 'should allow the active player to end the turn', (done) ->
      done = doneCount done, 4
      activeSocket = harness.getActiveSocket()

      harness.expectActive 'your-turn', (data)->
        data = data[harness.getActiveUser()]
        should.exist(data)
        done()

      harness.expectActive 'draw-cards', (data) ->
        data = data[harness.getActiveUser()]
        should.exist(data)
        cards = data[0]
        should.exist(cards)
        cards.should.be.instanceOf(Array)
        done()

      harness.expectInactive 'opponent-turn', (data)->
        data = data[harness.getInactiveUsers()[0]]
        should.exist(data)
        userTurn = data[0]
        userTurn.should.eql harness.getActiveUser()
        done()

      activeSocket.emit 'end-turn', (err) ->
        should.not.exist(err)
        done()

    it 'should not allow the same card to be played twice', (done) ->
      done = doneCount done, 1
      activeSocket = harness.getActiveSocket()
      cards = harness.getDrawnCards harness.getActiveUser()
      activeSocket.emit 'test', 'energy', 1000, ->
        activeSocket.emit 'play-card', cards[0]._id, null, (err, card) ->
          should.not.exist(err)
          should.exist(card)
          harness.updateCard harness.getActiveUser(), card
          activeSocket.emit 'play-card', cards[0]._id, null, (err, card) ->
            should.exist(err)
            done()

    it 'should not allow a sleeping card to be used', (done) ->
      socket = harness.getActiveSocket()
      targetCard = harness.getFieldCards(harness.getInactiveUsers()[0])[0]
      fieldCards = harness.getFieldCards harness.getActiveUser()
      should.exist(fieldCards)
      fieldCards.should.have.length(1)
      card = fieldCards[0]
      if 'sleeping' in card.status
        socket.emit 'use-card', card._id, {card:targetCard._id}, (err, actions) ->
          should.exist(err)
          err.should.have.property 'id', 'CARD_SLEEPING'
          done()
      else
        done()

    it 'should update sleeping cards to not sleeping when the turn is over', (done) ->
      socket = harness.getActiveSocket()
      harness.expectActive 'your-turn', (data) ->
        data = data[harness.getActiveUser()]
        done()

      socket.emit 'end-turn', (err, actions) ->
        should.not.exist(err)
        should.exist(actions)
        actions[0].type.should.eql('card-status-remove')
        actions[0].status.should.eql('sleeping')

