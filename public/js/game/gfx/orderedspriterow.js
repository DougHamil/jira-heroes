// Generated by CoffeeScript 1.6.3
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['gfx/styles', 'util', 'engine', 'pixi', 'tween'], function(STYLES, Util, engine) {
    /*
    # Presents sprites as a row and allows sprites to be added and removed from the row
    */

    var OrderedSpriteRow;
    return OrderedSpriteRow = (function() {
      function OrderedSpriteRow(origin, widthPerSprite, padding, animTime) {
        this.origin = origin;
        this.widthPerSprite = widthPerSprite;
        this.padding = padding;
        this.animTime = animTime;
        this.sprites = [];
      }

      OrderedSpriteRow.prototype.reorder = function(animStartCb, animEndPartialCb) {
        var index, pos, sprite, _i, _len, _ref, _results;
        index = 0;
        _ref = this.sprites;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          sprite = _ref[_i];
          pos = this.getPositionAt(index);
          if (sprite.position.x !== pos.x || sprite.position.y !== pos.y) {
            sprite.tween = Util.spriteTween(sprite, sprite.position, pos, this.animTime);
            if (animStartCb != null) {
              animStartCb(sprite);
            }
            sprite.tween.start();
            if (animEndPartialCb != null) {
              sprite.tween.onComplete(animEndPartialCb(sprite));
            }
          }
          _results.push(index++);
        }
        return _results;
      };

      OrderedSpriteRow.prototype.getPositionAt = function(idx) {
        return {
          x: this.origin.x + (this.widthPerSprite * idx) + (this.padding * idx),
          y: this.origin.y
        };
      };

      OrderedSpriteRow.prototype.getNextPosition = function() {
        return this.getPositionAt(this.sprites.length);
      };

      OrderedSpriteRow.prototype.addSprite = function(sprite, animate, completeCb) {
        var position;
        position = this.getNextPosition();
        if (animate) {
          sprite.tween = Util.spriteTween(sprite, sprite.position, position, this.animTime);
          sprite.tween.start();
          if (completeCb != null) {
            sprite.tween.onComplete(completeCb);
          }
        } else {
          sprite.position = position;
          if (completeCb != null) {
            completeCb();
          }
        }
        this.sprites.push(sprite);
        return position;
      };

      OrderedSpriteRow.prototype.removeSprite = function(sprite) {
        return this.sprites = this.sprites.filter(function(s) {
          return s !== sprite;
        });
      };

      OrderedSpriteRow.prototype.hasSprite = function(sprite) {
        return __indexOf.call(this.sprites, sprite) >= 0;
      };

      return OrderedSpriteRow;

    })();
  });

}).call(this);