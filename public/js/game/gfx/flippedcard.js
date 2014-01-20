// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['gfx/styles', 'util', 'pixi', 'tween'], function(STYLES, Util) {
    var CARD_SIZE, FACE_TEXTURE, FlippedCard, IMAGE_PATH;
    CARD_SIZE = {
      width: 150,
      height: 214
    };
    IMAGE_PATH = "/media/images/cards/";
    FACE_TEXTURE = PIXI.Texture.fromImage(IMAGE_PATH + 'card_reverse.png');
    /*
    # Draws a flipped card, basically just the backside of the card
    */

    return FlippedCard = (function(_super) {
      __extends(FlippedCard, _super);

      function FlippedCard() {
        FlippedCard.__super__.constructor.apply(this, arguments);
        this.width = CARD_SIZE.width;
        this.height = CARD_SIZE.height;
        this.faceSprite = new PIXI.Sprite(FACE_TEXTURE);
        this.faceSprite.width = this.width;
        this.faceSprite.height = this.height;
        this.addChild(this.faceSprite);
      }

      return FlippedCard;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);