// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'gui', 'engine', 'util', 'pixi'], function($, GUI, engine, Util) {
    var CardManager, HAND_ANIM_TIME, HAND_HOVER_OFFSET, HAND_ORIGIN, HAND_PADDING, HOVER_ANIM_TIME;
    HAND_ORIGIN = {
      x: 20,
      y: engine.HEIGHT - 20
    };
    HAND_ANIM_TIME = 1000;
    HAND_HOVER_OFFSET = 50;
    HAND_PADDING = 20;
    HOVER_ANIM_TIME = 200;
    /*
    # Manages all card sprites in the battle by positioning and animating them
    # as the battle unfolds.
    */

    return CardManager = (function(_super) {
      __extends(CardManager, _super);

      function CardManager(cardClasses, userId, battle) {
        var card, _i, _len, _ref,
          _this = this;
        this.cardClasses = cardClasses;
        this.userId = userId;
        this.battle = battle;
        CardManager.__super__.constructor.apply(this, arguments);
        this.cardSprites = {};
        this.handSprites = [];
        _ref = this.battle.getCardsInHand();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          card = _ref[_i];
          this.putCardInHand(card, false);
        }
        engine.updateCallbacks.push(function() {
          return _this.update();
        });
      }

      CardManager.prototype.putCardInHand = function(card, animate) {
        var addInteraction, position, sprite, tween,
          _this = this;
        if (animate == null) {
          animate = true;
        }
        sprite = this.getCardSprite(card);
        position = this.getOpenHandPosition();
        addInteraction = function(sprite) {
          return function() {
            var from, to;
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
              tween = Util.spriteTween(sprite, sprite.position, to, HOVER_ANIM_TIME);
              tween.start();
              return sprite.tween = tween;
            });
            sprite.onHoverEnd(function() {
              var tween;
              if (_this.dragSprite !== sprite) {
                tween = Util.spriteTween(sprite, sprite.position, from, HOVER_ANIM_TIME);
                tween.start();
                return sprite.tween = tween;
              }
            });
            sprite.onMouseDown(function() {
              if (sprite.tween != null) {
                sprite.tween.stop();
                _this.dragOffset = _this.stage.getMousePosition().clone();
                _this.dragOffset.x -= sprite.position.x;
                _this.dragOffset.y -= sprite.position.y;
                return _this.dragSprite = sprite;
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
                tween.start();
                return sprite.tween = tween;
              }
            });
          };
        };
        if (animate) {
          tween = Util.spriteTween(sprite, sprite.position, position, HAND_ANIM_TIME).start();
          sprite.tween = tween;
          tween.onComplete(addInteraction(sprite));
        } else {
          sprite.position = position;
          addInteraction(sprite)();
        }
        return this.handSprites.push(sprite);
      };

      CardManager.prototype.update = function() {
        var pos;
        if ((this.dragSprite != null) && (this.stage != null)) {
          pos = this.stage.getMousePosition().clone();
          pos.x -= this.dragOffset.x;
          pos.y -= this.dragOffset.y;
          return this.dragSprite.position = pos;
        }
      };

      CardManager.prototype.getOpenHandPosition = function() {
        return {
          x: HAND_ORIGIN.x + (this.getCardWidth() + HAND_PADDING) * this.handSprites.length,
          y: HAND_ORIGIN.y - this.getCardHeight()
        };
      };

      CardManager.prototype.getCardHeight = function() {
        var id, sprite, _ref;
        _ref = this.cardSprites;
        for (id in _ref) {
          sprite = _ref[id];
          return sprite.height;
        }
        return 0;
      };

      CardManager.prototype.getCardWidth = function() {
        var id, sprite, _ref;
        _ref = this.cardSprites;
        for (id in _ref) {
          sprite = _ref[id];
          return sprite.width;
        }
        return 0;
      };

      CardManager.prototype.getCardSprite = function(card) {
        var sprite;
        sprite = this.cardSprites[card._id];
        if (sprite == null) {
          sprite = this.buildSpriteForCard(card);
          sprite.card = card;
          this.cardSprites[card._id] = sprite;
          this.addChild(sprite);
        }
        return sprite;
      };

      CardManager.prototype.buildSpriteForCard = function(card) {
        return new GUI.Card(this.cardClasses[card["class"]], card.damage, card.health, card.status);
      };

      return CardManager;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);