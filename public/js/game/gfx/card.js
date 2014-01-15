// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['gfx/styles', 'util', 'pixi', 'tween'], function(styles, Util) {
    var BACKGROUND_TEXTURE, CARD_SIZE, Card, IMAGE_PATH, IMAGE_POS, IMAGE_SIZE, MISSING_TEXTURE;
    IMAGE_SIZE = {
      width: 64,
      height: 64
    };
    CARD_SIZE = {
      width: 150,
      height: 214
    };
    IMAGE_POS = {
      x: CARD_SIZE.width / 2,
      y: 22
    };
    IMAGE_PATH = '/media/images/cards/';
    BACKGROUND_TEXTURE = PIXI.Texture.fromImage(IMAGE_PATH + 'background.png');
    MISSING_TEXTURE = PIXI.Texture.fromImage(IMAGE_PATH + 'missing.png');
    /*
    # Draws everything for a card, showing the image, damage, heatlh, status, etc.
    */

    return Card = (function(_super) {
      __extends(Card, _super);

      Card.FromClass = function(cardClass) {
        return new Card(cardClass, cardClass.damage, cardClass.health, []);
      };

      function Card(cardClass, damage, health, status) {
        var imageTexture;
        Card.__super__.constructor.call(this);
        imageTexture = PIXI.Texture.fromImage(IMAGE_PATH + cardClass.media.image);
        if (!imageTexture.baseTexture.hasLoaded) {
          console.log("Error loading " + cardClass.media.image);
          imageTexture = MISSING_TEXTURE;
        }
        this.backgroundSprite = new PIXI.Sprite(BACKGROUND_TEXTURE);
        this.backgroundSprite.width = CARD_SIZE.width;
        this.backgroundSprite.height = CARD_SIZE.height;
        this.imageSprite = new PIXI.Sprite(imageTexture);
        this.imageSprite.width = IMAGE_SIZE.width;
        this.imageSprite.height = IMAGE_SIZE.height;
        this.titleText = new PIXI.Text(cardClass.displayName, styles.CARD_TITLE);
        this.healthText = new PIXI.Text(health.toString(), styles.CARD_STAT);
        this.damageText = new PIXI.Text(damage.toString(), styles.CARD_STAT);
        this.description = this.buildAbilityText(cardClass);
        this.description.anchor = {
          x: 0.5,
          y: 0
        };
        this.description.position = {
          x: this.backgroundSprite.width / 2,
          y: this.backgroundSprite.height / 2
        };
        this.titleText.anchor = {
          x: 0.5,
          y: 0
        };
        this.titleText.position = {
          x: this.backgroundSprite.width / 2,
          y: 0
        };
        this.healthText.anchor = {
          x: 0.5,
          y: 0.5
        };
        this.healthText.position = {
          x: this.backgroundSprite.width,
          y: this.backgroundSprite.height
        };
        this.damageText.anchor = {
          x: 0.5,
          y: 0.5
        };
        this.damageText.position = {
          x: 0,
          y: this.backgroundSprite.height
        };
        this.imageSprite.anchor = {
          x: 0.5,
          y: 0
        };
        this.imageSprite.position = {
          x: IMAGE_POS.x,
          y: IMAGE_POS.y
        };
        this.addChild(this.backgroundSprite);
        this.addChild(this.imageSprite);
        this.addChild(this.titleText);
        this.addChild(this.description);
        this.addChild(this.healthText);
        this.addChild(this.damageText);
        this.width = CARD_SIZE.width;
        this.height = CARD_SIZE.height;
        this.hitArea = new PIXI.Rectangle(0, 0, this.width, this.height);
        this.interactive = true;
      }

      Card.prototype.onHoverStart = function(cb) {
        var _this = this;
        return this.mouseover = function() {
          return cb(_this);
        };
      };

      Card.prototype.onHoverEnd = function(cb) {
        var _this = this;
        return this.mouseout = function() {
          return cb(_this);
        };
      };

      Card.prototype.onClick = function(cb) {
        var _this = this;
        return this.click = function() {
          return cb(_this);
        };
      };

      Card.prototype.buildAbilityText = function(cardClass) {
        var ability, chunk, chunks, count, parent, prop, string, text, _i, _j, _len, _len1, _ref;
        parent = new PIXI.DisplayObjectContainer;
        count = 0;
        _ref = cardClass.passiveAbilities;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ability = _ref[_i];
          chunks = ability.text.split(' ');
          string = "";
          for (_j = 0, _len1 = chunks.length; _j < _len1; _j++) {
            chunk = chunks[_j];
            if (/^<\w+>$/.test(chunk)) {
              prop = chunk.replace(/[<>]/g, '');
              chunk = ability.data[prop];
            }
            string += chunk + ' ';
          }
          text = new PIXI.Text(string, styles.CARD_DESCRIPTION);
          text.position = {
            x: 0,
            y: count * text.height
          };
          count++;
          parent.addChild(text);
        }
        return parent;
      };

      return Card;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
