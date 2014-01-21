// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['jquery', 'gui', 'engine', 'util', 'pixi'], function($, GUI, engine, Util) {
    var CardAnimator, DECK_ORIGIN, DEFAULT_TWEEN_TIME, DISCARD_ORIGIN, ENEMY_DECK_ORIGIN, ENEMY_FIELD_ORIGIN, ENEMY_HAND_ORIGIN, ENEMY_HERO_ORIGIN, FIELD_AREA, FIELD_ORIGIN, FIELD_PADDING, HAND_ANIM_TIME, HAND_HOVER_OFFSET, HAND_ORIGIN, HAND_PADDING, HERO_ORIGIN, HOVER_ANIM_TIME, TOKEN_CARD_OFFSET;
    DECK_ORIGIN = {
      x: engine.WIDTH + 200,
      y: engine.HEIGHT
    };
    ENEMY_DECK_ORIGIN = {
      x: engine.WIDTH + 200,
      y: 100
    };
    DISCARD_ORIGIN = {
      x: -200,
      y: 0
    };
    FIELD_PADDING = 50;
    ENEMY_HAND_ORIGIN = {
      x: 20,
      y: -100
    };
    HAND_ANIM_TIME = 1000;
    HAND_HOVER_OFFSET = 50;
    HAND_ORIGIN = {
      x: 20,
      y: engine.HEIGHT + HAND_HOVER_OFFSET - GUI.Card.Height
    };
    HAND_PADDING = 20;
    HOVER_ANIM_TIME = 200;
    DEFAULT_TWEEN_TIME = 400;
    TOKEN_CARD_OFFSET = 10;
    FIELD_AREA = new PIXI.Rectangle(10, 400, engine.WIDTH - 20, 220);
    FIELD_ORIGIN = {
      x: 20,
      y: FIELD_AREA.y + 10
    };
    ENEMY_FIELD_ORIGIN = {
      x: 20,
      y: 160
    };
    HERO_ORIGIN = {
      x: engine.WIDTH - GUI.HeroToken.Width - 20,
      y: FIELD_ORIGIN.y
    };
    ENEMY_HERO_ORIGIN = {
      x: engine.WIDTH - GUI.HeroToken.Width - 20,
      y: ENEMY_FIELD_ORIGIN.y
    };
    /*
    # Manages all card sprites in the battle by positioning and animating them
    # as the battle unfolds.
    */

    return CardAnimator = (function(_super) {
      __extends(CardAnimator, _super);

      function CardAnimator(heroClasses, cardClasses, userId, battle) {
        var card, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3,
          _this = this;
        this.heroClasses = heroClasses;
        this.cardClasses = cardClasses;
        this.userId = userId;
        this.battle = battle;
        CardAnimator.__super__.constructor.apply(this, arguments);
        this.cardSpriteLayer = new PIXI.DisplayObjectContainer();
        this.tokenSpriteLayer = new PIXI.DisplayObjectContainer();
        this.addChild(this.tokenSpriteLayer);
        this.addChild(this.cardSpriteLayer);
        this.flippedCardSprites = {};
        this.cardSprites = {};
        this.tokenSprites = {};
        this.cardTokens = {};
        this.heroTokens = {};
        this.buildHeroTokens(this.battle.getHero(), this.battle.getEnemyHero(), this.heroClasses);
        this.handSpriteRow = new GUI.OrderedSpriteRow(HAND_ORIGIN, GUI.Card.Width, HAND_PADDING, HAND_ANIM_TIME);
        this.fieldSpriteRow = new GUI.OrderedSpriteRow(FIELD_ORIGIN, GUI.CardToken.Width, FIELD_PADDING, DEFAULT_TWEEN_TIME);
        this.enemyHandSpriteRow = new GUI.OrderedSpriteRow(ENEMY_HAND_ORIGIN, GUI.Card.Width, HAND_PADDING, HAND_ANIM_TIME);
        this.enemyFieldSpriteRow = new GUI.OrderedSpriteRow(ENEMY_FIELD_ORIGIN, GUI.CardToken.Width, FIELD_PADDING, DEFAULT_TWEEN_TIME);
        _ref = this.battle.getCardsInHand();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          card = _ref[_i];
          this.putCardInHand(card, false);
        }
        _ref1 = this.battle.getEnemyCardsInHand();
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          card = _ref1[_j];
          this.putEnemyCardInHand(card, false);
        }
        _ref2 = this.battle.getCardsOnField();
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          card = _ref2[_k];
          this.putCardOnField(card, false);
        }
        _ref3 = this.battle.getEnemyCardsOnField();
        for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
          card = _ref3[_l];
          this.putEnemyCardOnField(card, false);
        }
        engine.updateCallbacks.push(function() {
          return _this.update();
        });
        document.body.onmouseup = function() {
          if (_this.targetingSource != null) {
            if (!_this.onTargeted(_this.targetingSource, _this.stage.getMousePosition().clone())) {
              if (_this.targetingSource.dropTween != null) {
                _this.targetingSource.dropTween.start();
              }
            }
            return _this.targetingSource = null;
          }
        };
        this.battle.on('action-draw-card', function(action) {
          return _this.onDrawCardAction(action);
        });
        this.battle.on('action-end-turn', function(action) {
          return _this.onEndTurnAction(action);
        });
        this.battle.on('action-play-card', function(action) {
          return _this.onPlayCardAction(action);
        });
        this.battle.on('action-cast-card', function(action) {
          return _this.onCastCardAction(action);
        });
        this.battle.on('action-damage', function(action) {
          return _this.onDamageAction(action);
        });
        this.battle.on('action-heal', function(action) {
          return _this.onHealAction(action);
        });
        this.battle.on('action-discard-card', function(action) {
          return _this.onDiscardCardAction(action);
        });
        this.battle.on('action-card-status-add', function(action) {
          return _this.onCardStatusAction(action);
        });
        this.battle.on('action-card-status-remove', function(action) {
          return _this.onCardStatusAction(action);
        });
      }

      CardAnimator.prototype.buildHeroTokens = function(hero, enemyHero, heroClasses) {
        console.log(heroClasses);
        this.heroTokens[hero._id] = new GUI.HeroToken(hero, heroClasses[hero["class"]]);
        this.heroTokens[enemyHero._id] = new GUI.HeroToken(enemyHero, heroClasses[enemyHero["class"]]);
        this.heroTokens[hero._id].position = HERO_ORIGIN;
        this.heroTokens[enemyHero._id].position = ENEMY_HERO_ORIGIN;
        this.tokenSpriteLayer.addChild(this.heroTokens[hero._id]);
        return this.tokenSpriteLayer.addChild(this.heroTokens[enemyHero._id]);
      };

      CardAnimator.prototype.onCardStatusAction = function(action) {
        var card, tokenSprite;
        card = this.battle.getCard(action.card);
        tokenSprite = this.getTokenSprite(card);
        if ((tokenSprite != null) && (card != null)) {
          return tokenSprite.setTaunt((__indexOf.call(card.status, 'taunt') >= 0));
        }
      };

      CardAnimator.prototype.onDiscardCardAction = function(action) {
        var cardSprite;
        cardSprite = this.getCardSprite(this.battle.getCard(action.card));
        return this.putCardInDiscard(this.cardSprites[action.card].card);
      };

      CardAnimator.prototype.updateHeroHealth = function(heroId) {
        var heroSprite;
        heroSprite = this.heroTokens[heroId];
        if (heroSprite != null) {
          return heroSprite.setHealth(this.battle.getHero(heroId).health);
        }
      };

      CardAnimator.prototype.updateCardHealth = function(cardId) {
        var cardSprite, tokenSprite;
        cardSprite = this.cardSprites[cardId];
        tokenSprite = this.tokenSprites[cardId];
        if (cardSprite != null) {
          cardSprite.setHealth(this.battle.getCard(cardId).health);
        }
        if (tokenSprite) {
          return tokenSprite.setHealth(this.battle.getCard(cardId).health);
        }
      };

      CardAnimator.prototype.onDamageAction = function(action) {
        this.updateCardHealth(action.target);
        return this.updateHeroHealth(action.target);
      };

      CardAnimator.prototype.onHealAction = function(action) {
        this.updateCardHealth(action.target);
        return this.updateHeroHealth(action.target);
      };

      CardAnimator.prototype.onPlayCardAction = function(action) {
        if (action.player !== this.userId) {
          return this.putEnemyCardOnField(action.card);
        }
      };

      CardAnimator.prototype.onCastCardAction = function(action) {};

      CardAnimator.prototype.onEndTurnAction = function(action) {
        this.fixHandPositions();
        return this.fixFieldPositions();
      };

      CardAnimator.prototype.onDrawCardAction = function(action) {
        if (action.player === this.userId) {
          return this.putCardInHand(action.card);
        } else {
          return this.putEnemyCardInHand(action.card);
        }
      };

      CardAnimator.prototype.setFieldTokenInteraction = function(tokenSprite, isTargetSource) {
        var cardPos,
          _this = this;
        cardPos = Util.clone(tokenSprite.position);
        cardPos.x += tokenSprite.width + TOKEN_CARD_OFFSET;
        tokenSprite.cardSprite.position = cardPos;
        tokenSprite.cardSprite.visible = false;
        tokenSprite.onHoverStart(function() {
          return tokenSprite.cardSprite.visible = true;
        });
        tokenSprite.onHoverEnd(function() {
          return tokenSprite.cardSprite.visible = false;
        });
        if (isTargetSource) {
          return tokenSprite.onMouseDown(function() {
            return _this.setTargetingSource(tokenSprite);
          });
        }
      };

      CardAnimator.prototype.placeFieldToken = function(spriteRow, cardSprite, tokenSprite, isTargetSource, animate) {
        var addInteraction, position, tween,
          _this = this;
        addInteraction = function(sprite) {
          return function() {
            _this.setFieldTokenInteraction(sprite, isTargetSource);
            return sprite.visible = true;
          };
        };
        position = spriteRow.addSprite(tokenSprite, false);
        tokenSprite.visible = false;
        if (animate) {
          tween = Util.spriteTween(cardSprite, cardSprite.position, position, DEFAULT_TWEEN_TIME);
          cardSprite.tween = tween;
          tween.start();
          return tween.onComplete(addInteraction(tokenSprite));
        } else {
          return addInteraction(tokenSprite)();
        }
      };

      CardAnimator.prototype.putCardInDiscard = function(card, animate) {
        var cardSprite, position, tokenSprite,
          _this = this;
        if (animate == null) {
          animate = true;
        }
        cardSprite = this.getCardSprite(card);
        tokenSprite = this.getTokenSprite(card);
        position = this.getDiscardPosition();
        if (this.fieldSpriteRow.hasSprite(tokenSprite) || this.enemyFieldSpriteRow.hasSprite(tokenSprite)) {
          tokenSprite.tween = Util.spriteTween(tokenSprite, tokenSprite.position, position, DEFAULT_TWEEN_TIME);
          tokenSprite.tween.onComplete(function() {
            return tokenSprite.visible = false;
          });
          tokenSprite.tween.start();
          tokenSprite.removeAllInteractions();
          cardSprite.visible = false;
        } else if (this.handSpriteRow.hasSprite(cardSprite) || this.enemyHandSpriteRow.hasSprite(cardSprite)) {
          cardSprite.tween = Util.spriteTween(cardSprite, cardSprite.position, position, DEFAULT_TWEEN_TIME);
          cardSprite.tween.onComplete(function() {
            return cardSprite.visible = false;
          });
          cardSprite.tween.start();
          cardSprite.removeAllInteractions();
          tokenSprite.visible = false;
        }
        this.fieldSpriteRow.removeSprite(tokenSprite);
        this.enemyFieldSpriteRow.removeSprite(tokenSprite);
        if (this.handSpriteRow.hasSprite(cardSprite)) {
          this.handSpriteRow.removeSprite(cardSprite);
        }
        if (this.enemyHandSpriteRow.hasSprite(cardSprite)) {
          return this.enemyHandSpriteRow.removeSprite(cardSprite);
        }
      };

      CardAnimator.prototype.putEnemyCardOnField = function(card, animate) {
        var cardSprite, handSprite, tokenSprite;
        if (animate == null) {
          animate = true;
        }
        cardSprite = this.getCardSprite(card);
        tokenSprite = this.getTokenSprite(card);
        if (animate) {
          handSprite = this.flippedCardSprites[card._id];
          if (handSprite != null) {
            if (this.enemyHandSpriteRow.hasSprite(handSprite)) {
              cardSprite.position = handSprite.position;
              this.cardSpriteLayer.removeChild(handSprite);
              this.enemyHandSpriteRow.removeSprite(handSprite);
            }
          }
        }
        this.placeFieldToken(this.enemyFieldSpriteRow, cardSprite, tokenSprite, false, animate);
        this.tokenSpriteLayer.addChild(tokenSprite);
        return this.cardSpriteLayer.addChild(cardSprite);
      };

      CardAnimator.prototype.putCardOnField = function(card, animate) {
        var cardSprite, tokenSprite;
        if (animate == null) {
          animate = true;
        }
        cardSprite = this.getCardSprite(card);
        tokenSprite = this.getTokenSprite(card);
        this.placeFieldToken(this.fieldSpriteRow, cardSprite, tokenSprite, true, animate);
        this.handSpriteRow.removeSprite(cardSprite);
        this.tokenSpriteLayer.addChild(tokenSprite);
        return this.cardSpriteLayer.addChild(cardSprite);
      };

      CardAnimator.prototype.setHandInteraction = function(sprite) {
        var cardClass, from, to,
          _this = this;
        cardClass = this.cardClasses[sprite.card["class"]];
        to = {
          x: sprite.position.x,
          y: sprite.position.y - HAND_HOVER_OFFSET
        };
        from = {
          x: sprite.position.x,
          y: sprite.position.y
        };
        sprite.onHoverStart(function() {
          var tween;
          if ((_this.dragSprite == null) && (_this.targetingSource == null)) {
            tween = Util.spriteTween(sprite, sprite.position, to, HOVER_ANIM_TIME);
            tween.start();
            return sprite.tween = tween;
          }
        });
        sprite.onHoverEnd(function() {
          var tween;
          if (_this.dragSprite !== sprite && _this.targetingSource !== sprite) {
            tween = Util.spriteTween(sprite, sprite.position, from, HOVER_ANIM_TIME);
            tween.start();
            return sprite.tween = tween;
          } else if (_this.targetingSource === sprite) {
            tween = Util.spriteTween(sprite, sprite.position, from, HOVER_ANIM_TIME);
            return sprite.dropTween = tween;
          }
        });
        sprite.onMouseDown(function() {
          if (cardClass.playAbility != null) {
            return _this.setTargetingSource(sprite);
          } else {
            if (sprite.tween != null) {
              sprite.tween.stop();
              _this.dragOffset = _this.stage.getMousePosition().clone();
              _this.dragOffset.x -= sprite.position.x;
              _this.dragOffset.y -= sprite.position.y;
              _this.dragSprite = sprite;
              _this.cardSpriteLayer.removeChild(_this.dragSprite);
              return _this.cardSpriteLayer.addChild(_this.dragSprite);
            }
          }
        });
        return sprite.onMouseUp(function() {
          var tween;
          if (sprite.tween != null) {
            sprite.tween.stop();
          }
          if (_this.dragSprite === sprite) {
            _this.dragSprite = null;
            tween = Util.spriteTween(sprite, sprite.position, from, HOVER_ANIM_TIME);
            sprite.tween = tween;
            return _this.onCardDropped(_this.stage.getMousePosition().clone(), sprite);
          }
        });
      };

      CardAnimator.prototype.putEnemyCardInHand = function(cardId, animate) {
        var sprite;
        if (animate == null) {
          animate = true;
        }
        sprite = this.flippedCardSprites[cardId] != null ? this.flippedCardSprites[cardId] : new GUI.FlippedCard();
        this.flippedCardSprites[cardId] = sprite;
        sprite.cardId = cardId;
        sprite.sourcePosition = this.enemyHandSpriteRow.addSprite(sprite, animate);
        return this.cardSpriteLayer.addChild(sprite);
      };

      CardAnimator.prototype.putCardInHand = function(card, animate) {
        var sprite,
          _this = this;
        if (animate == null) {
          animate = true;
        }
        sprite = this.getCardSprite(card);
        if (animate && sprite.position.x === 0 && sprite.position.y === 0) {
          sprite.position = Util.clone(DECK_ORIGIN);
        }
        sprite.sourcePosition = this.handSpriteRow.addSprite(sprite, animate, function() {
          return _this.setHandInteraction(sprite);
        });
        return this.cardSpriteLayer.addChild(sprite);
      };

      CardAnimator.prototype.fixHandPositions = function() {
        var removeInteractions, setInteractions,
          _this = this;
        removeInteractions = function(sprite) {
          return _this.removeInteractions(sprite);
        };
        setInteractions = function(sprite) {
          return function() {
            return _this.setHandInteraction(sprite);
          };
        };
        this.handSpriteRow.reorder(removeInteractions, setInteractions);
        return this.enemyHandSpriteRow.reorder();
      };

      CardAnimator.prototype.fixFieldPositions = function() {
        var removeInteractions, setEnemyInteractions, setInteractions,
          _this = this;
        removeInteractions = function(sprite) {
          return _this.removeInteractions(sprite);
        };
        setInteractions = function(sprite) {
          return function() {
            return _this.setFieldTokenInteraction(sprite, true);
          };
        };
        setEnemyInteractions = function(sprite) {
          return function() {
            return _this.setFieldTokenInteraction(sprite, false);
          };
        };
        this.fieldSpriteRow.reorder(removeInteractions, setInteractions);
        return this.enemyFieldSpriteRow.reorder(removeInteractions, setEnemyInteractions);
      };

      CardAnimator.prototype.onTargeted = function(sourceSprite, targetPosition) {
        var cardId, foundTarget, heroId, heroTokenSprite, tokenSprite, _ref, _ref1,
          _this = this;
        foundTarget = false;
        _ref = this.tokenSprites;
        for (cardId in _ref) {
          tokenSprite = _ref[cardId];
          if (tokenSprite.contains(targetPosition)) {
            if (this.handSpriteRow.hasSprite(sourceSprite)) {
              foundTarget = true;
              this.battle.emitPlayCardEvent(sourceSprite.card._id, {
                card: cardId
              }, function(err) {
                if (err != null) {
                  console.log(err);
                  if (sourceSprite.dropTween != null) {
                    return sourceSprite.dropTween.start();
                  } else if (sourceSprite.tween != null) {
                    return sourceSprite.tween.start();
                  }
                }
              });
            } else if (this.fieldSpriteRow.hasSprite(sourceSprite)) {
              foundTarget = true;
              this.battle.emitUseCardEvent(sourceSprite.card._id, {
                card: cardId
              }, function(err) {
                if (err != null) {
                  console.log(err);
                  if (sourceSprite.dropTween != null) {
                    return sourceSprite.dropTween.start();
                  }
                }
              });
            }
            break;
          }
        }
        _ref1 = this.heroTokens;
        for (heroId in _ref1) {
          heroTokenSprite = _ref1[heroId];
          if (heroTokenSprite.contains(targetPosition)) {
            console.log(heroId);
            if (this.handSpriteRow.hasSprite(sourceSprite)) {
              foundTarget = true;
              this.battle.emitPlayCardEvent(sourceSprite.card._id, {
                hero: heroId
              }, function(err) {
                if (err != null) {
                  console.log(err);
                  if (sourceSprite.dropTween != null) {
                    return sourceSprite.dropTween.start();
                  } else if (sourceSprite.tween != null) {
                    return sourceSprite.tween.start();
                  }
                }
              });
            } else if (this.fieldSpriteRow.hasSprite(sourceSprite)) {
              foundTarget = true;
              this.battle.emitUseCardEvent(sourceSprite.card._id, {
                hero: heroId
              }, function(err) {
                if (err != null) {
                  console.log(err);
                  if (sourceSprite.dropTween != null) {
                    return sourceSprite.dropTween.start();
                  }
                }
              });
            }
            break;
          }
        }
        return foundTarget;
      };

      CardAnimator.prototype.onCardDropped = function(mousePosition, sprite) {
        var card, cardClass, played,
          _this = this;
        played = false;
        if (FIELD_AREA.contains(mousePosition.x, mousePosition.y)) {
          card = sprite.card;
          cardClass = this.cardClasses[card["class"]];
          this.battle.emitPlayCardEvent(sprite.card._id, null, function(err) {
            if (err != null) {
              console.log(err);
              return sprite.tween.start();
            } else {
              console.log("Played card " + sprite.card._id);
              _this.removeInteractions(sprite);
              _this.putCardOnField(sprite.card);
              if (cardClass.rushAbility != null) {
                sprite.dropTween = null;
                return _this.setTargetingSource(_this.getTokenSprite(sprite.card));
              }
            }
          });
          played = true;
        }
        if (!played) {
          return sprite.tween.start();
        }
      };

      CardAnimator.prototype.removeInteractions = function(cardSprite) {
        return cardSprite.removeAllInteractions();
      };

      CardAnimator.prototype.update = function() {
        var pos, sourcePos;
        if (this.targetingSprite != null) {
          this.removeChild(this.targetingSprite);
          this.targetingSprite = null;
        }
        if (this.stage != null) {
          if (this.dragSprite != null) {
            pos = this.stage.getMousePosition().clone();
            pos.x -= this.dragOffset.x;
            pos.y -= this.dragOffset.y;
            return this.dragSprite.position = pos;
          } else if (this.targetingSource != null) {
            pos = this.stage.getMousePosition().clone();
            sourcePos = {
              x: this.targetingSource.position.x + this.targetingSource.width / 2,
              y: this.targetingSource.position.y + this.targetingSource.height / 2
            };
            this.targetingSprite = this.createTargetingSprite(sourcePos, pos);
            return this.addChild(this.targetingSprite);
          }
        }
      };

      CardAnimator.prototype.setTargetingSource = function(sprite) {
        return this.targetingSource = sprite;
      };

      CardAnimator.prototype.getDiscardPosition = function() {
        return DISCARD_ORIGIN;
      };

      CardAnimator.prototype.getTokenSprite = function(card) {
        var sprite;
        sprite = this.tokenSprites[card._id];
        if (sprite == null) {
          sprite = new GUI.CardToken(card, this.cardClasses[card["class"]]);
          sprite.card = card;
          sprite.cardSprite = this.getCardSprite(card);
          this.tokenSprites[card._id] = sprite;
        }
        return sprite;
      };

      CardAnimator.prototype.getCardSprite = function(card) {
        var sprite;
        sprite = this.cardSprites[card._id];
        if (sprite == null) {
          sprite = this.buildSpriteForCard(card);
          sprite.card = card;
          this.cardSprites[card._id] = sprite;
        }
        return sprite;
      };

      CardAnimator.prototype.createTargetingSprite = function(start, end) {
        var s;
        s = new PIXI.Graphics();
        s.beginFill();
        s.lineStyle(10, 0x000000, 1.0);
        s.moveTo(start.x, start.y);
        s.lineTo(end.x, end.y);
        s.endFill();
        return s;
      };

      CardAnimator.prototype.buildSpriteForCard = function(card) {
        return new GUI.Card(this.cardClasses[card["class"]], card.damage, card.health, card.status);
      };

      return CardAnimator;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
