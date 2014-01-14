ActionProcessor = require '../../src/game/actionprocessor'
AttackAbility = require '../../src/game/abilities/attack'
HealAbility = require '../../src/game/abilities/heal'
MockBattle = require './mockbattle'
should = require 'should'

describe 'Basic Scenarios', ->
  it 'should handle a card damaging another card', ->
    battle = new MockBattle()
    sourcePlayer = battle.NewPlayer()
    targetPlayer = battle.NewPlayer()
    sourceCard = battle.NewCard(sourcePlayer)
    targetCard = battle.NewCard(targetPlayer)
    targetCard.health = 5
    sourceCard.damage = 1

    # Cast the attack ability on the target card
    attackAbility = new AttackAbility sourceCard
    actions = attackAbility.cast battle, targetCard
    # Process the abilities
    targetCard.should.have.property('health', 5)
    ActionProcessor.process battle, actions, []
    targetCard.should.have.property('health', 4)

  it 'should handle a card killing another card', ->
    battle = new MockBattle()
    sourcePlayer = battle.NewPlayer()
    targetPlayer = battle.NewPlayer()
    sourceCard = battle.NewCard(sourcePlayer)
    targetCard = battle.NewCard(targetPlayer)
    targetCard.health = 5
    sourceCard.damage = 6

    # Cast the attack ability on the target card
    attackAbility = new AttackAbility sourceCard
    actions = attackAbility.cast battle, targetCard
    # Process the abilities
    targetCard.should.have.property('health', 5)
    ActionProcessor.process battle, actions, []
    targetCard.should.have.property('health', -1)
    targetCard.should.have.property('position', 'discard')

  it 'should handle a card healing another card', ->
    battle = new MockBattle()
    sourcePlayer = battle.NewPlayer()
    targetPlayer = battle.NewPlayer()
    sourceCard = battle.NewCard(sourcePlayer)
    targetCard = battle.NewCard(targetPlayer)
    targetCard.health = 5
    targetCard.maxHealth = 8
    sourceCard.damage = 6

    # Cast the heal ability on the target
    healAbility = new HealAbility sourceCard, {amount: 10}
    actions = healAbility.cast battle, targetCard
    # Process the abilities
    targetCard.should.have.property('health', 5)
    ActionProcessor.process battle, actions, []
    # Target should not exceed max health on heal
    targetCard.should.have.property('health', 8)

    targetCard.maxHealth = 12
    healAbility = new HealAbility sourceCard, {amount:2}
    actions = healAbility.cast battle, targetCard
    targetCard.should.have.property('health', 8)
    ActionProcessor.process battle, actions, []
    # Target should not be healed more than the ability's amount
    targetCard.should.have.property('health', 10)
