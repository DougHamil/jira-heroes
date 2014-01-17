// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['gfx/styles', 'gfx/deckbutton', 'util', 'engine', 'pixi', 'tween'], function(STYLES, DeckButton, Util, engine) {
    var DECK_BUTTON_PADDING, DeckPicker, HEIGHT, WIDTH;
    HEIGHT = engine.HEIGHT - 100;
    WIDTH = engine.WIDTH - engine.WIDTH / 4;
    DECK_BUTTON_PADDING = 10;
    /*
    # Provides an interface for selecting a deck
    */

    return DeckPicker = (function(_super) {
      __extends(DeckPicker, _super);

      function DeckPicker(decks, heroes) {
        var deck, deckBtn, onDeckButtonClicked, y, _i, _len, _ref,
          _this = this;
        this.decks = decks;
        this.heroes = heroes;
        DeckPicker.__super__.constructor.apply(this, arguments);
        this.deckButtons = {};
        y = 0;
        onDeckButtonClicked = function(deckId) {
          return function() {
            if (_this.onDeckPickedCallback != null) {
              return _this.onDeckPickedCallback(deckId);
            }
          };
        };
        _ref = this.decks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          deck = _ref[_i];
          deckBtn = new DeckButton(deck, this.heroes[deck.hero["class"]]);
          this.addChild(deckBtn);
          deckBtn.position = {
            x: 0,
            y: y
          };
          deckBtn.onClick(onDeckButtonClicked(deck._id));
          y += deckBtn.height + DECK_BUTTON_PADDING;
          this.deckButtons[deck._id] = deckBtn;
        }
      }

      DeckPicker.prototype.onDeckPicked = function(onDeckPickedCallback) {
        this.onDeckPickedCallback = onDeckPickedCallback;
      };

      DeckPicker.prototype.setHighlight = function(deckId, highlight) {
        return this.deckButtons[deckId].setHighlight(highlight);
      };

      return DeckPicker;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);