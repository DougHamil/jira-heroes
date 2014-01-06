// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], function($, JH, GUI, engine) {
    var CARDS_PER_ROW, CARD_PADDING, COST_SPRITE_PADDING, Library, PAGE_POS, ROWS_PER_PAGE;
    COST_SPRITE_PADDING = 10;
    PAGE_POS = {
      x: 50,
      y: 100
    };
    CARD_PADDING = 50;
    CARDS_PER_ROW = 4;
    ROWS_PER_PAGE = 2;
    return Library = (function(_super) {
      __extends(Library, _super);

      function Library(manager, myStage) {
        var _this = this;
        this.manager = manager;
        this.myStage = myStage;
        Library.__super__.constructor.apply(this, arguments);
        this.heading = new PIXI.Text('Library', GUI.STYLES.HEADING);
        this.nextBtn = new GUI.TextButton('Next Page');
        this.prevBtn = new GUI.TextButton('Last Page');
        this.backBtn = new GUI.TextButton('Back');
        this.nextBtn.position = {
          x: engine.WIDTH - this.nextBtn.width - 20,
          y: engine.HEIGHT - 200
        };
        this.nextBtn.onClick(function() {
          return _this.nextPage();
        });
        this.prevBtn.onClick(function() {
          return _this.prevPage();
        });
        this.prevBtn.position = {
          x: 20,
          y: engine.HEIGHT - 200
        };
        this.backBtn.position = {
          x: 20,
          y: engine.HEIGHT - this.backBtn.height - 20
        };
        this.backBtn.onClick(function() {
          return _this.manager.activateView('MainMenu');
        });
        this.addChild(this.heading);
        this.addChild(this.backBtn);
        this.addChild(this.nextBtn);
        this.addChild(this.prevBtn);
      }

      Library.prototype.deactivate = function() {
        this.myStage.removeChild(this);
        if (JH.pointsText != null) {
          this.removeChild(JH.pointsText);
        }
        if (JH.nameText != null) {
          this.removeChild(JH.nameText);
        }
        return this.removeChild(this.pages[this.pageIndex]);
      };

      Library.prototype.nextPage = function() {
        return this.setPageIndex(this.pageIndex + 1);
      };

      Library.prototype.prevPage = function() {
        return this.setPageIndex(this.pageIndex - 1);
      };

      Library.prototype.setPageIndex = function(index) {
        if (index >= this.pages.length || index < 0 || index === this.pageIndex) {

        } else {
          if (this.pageIndex === 0) {
            this.addChild(this.prevBtn);
          }
          if (this.pageIndex === (this.pages.length - 1)) {
            this.addChild(this.nextBtn);
          }
          if (index === (this.pages.length - 1)) {
            this.removeChild(this.nextBtn);
          } else if (index === 0) {
            this.removeChild(this.prevBtn);
          }
          if (this.pageIndex != null) {
            this.removeChild(this.pages[this.pageIndex]);
          }
          this.pageIndex = index;
          return this.addChild(this.pages[this.pageIndex]);
        }
      };

      Library.prototype.activate = function(hero) {
        var activate,
          _this = this;
        this.hero = hero;
        activate = function(cards) {
          var buyCard, card, cardIndex, cardSprite, pageContainer, xpos, ypos, _i, _len;
          _this.updateLibrary(JH.user.library);
          JH.cards = cards;
          _this.cardsById = {};
          _this.cardSprites = {};
          _this.pages = [];
          pageContainer = new PIXI.DisplayObjectContainer;
          cardIndex = 0;
          for (_i = 0, _len = cards.length; _i < _len; _i++) {
            card = cards[_i];
            cardSprite = GUI.Card.FromClass(card);
            pageContainer.addChild(cardSprite);
            cardSprite.onHoverStart(function(card) {
              card.scale.x += 0.1;
              return card.scale.y += 0.1;
            });
            cardSprite.onHoverEnd(function(card) {
              card.scale.x -= 0.1;
              return card.scale.y -= 0.1;
            });
            xpos = CARD_PADDING + ((cardIndex % CARDS_PER_ROW) * (CARD_PADDING + cardSprite.width));
            ypos = Math.floor(cardIndex / CARDS_PER_ROW) * (CARD_PADDING + cardSprite.height);
            cardSprite.position.x = xpos;
            cardSprite.position.y = ypos;
            if (_this.library[card._id] == null) {
              buyCard = function(cardId) {
                return function() {
                  return JH.AddCardToUserLibrary(cardId, _this.onCardBought(cardId), _this.onCardBuyFail(cardId));
                };
              };
              cardSprite.onClick(buyCard(card._id));
            }
            _this.cardsById[card._id] = card;
            _this.cardSprites[card._id] = cardSprite;
            cardIndex++;
            if (cardIndex === (CARDS_PER_ROW * ROWS_PER_PAGE)) {
              pageContainer.position = PAGE_POS;
              cardIndex = 0;
              _this.pages.push(pageContainer);
              pageContainer = new PIXI.DisplayObjectContainer;
              pageContainer.position = PAGE_POS;
            }
          }
          if (cardIndex !== 0) {
            _this.pages.push(pageContainer);
          }
          _this.addCostSprites(JH.user, _this.library, _this.cardSprites, _this.cardsById);
          _this.setPageIndex(0);
          _this.addChild(JH.pointsText);
          _this.addChild(JH.nameText);
          return _this.myStage.addChild(_this);
        };
        if (JH.cards == null) {
          return JH.GetAllCards(activate);
        } else {
          return activate(JH.cards);
        }
      };

      Library.prototype.updateLibrary = function(userLibrary) {
        var cardId, _i, _len, _results;
        this.library = {};
        _results = [];
        for (_i = 0, _len = userLibrary.length; _i < _len; _i++) {
          cardId = userLibrary[_i];
          _results.push(this.library[cardId] = true);
        }
        return _results;
      };

      Library.prototype.onCardBuyFail = function(cardId) {
        var _this = this;
        return function() {
          console.log(arguments);
          return console.log("Card buying failed for card " + cardId);
        };
      };

      Library.prototype.onCardBought = function(cardId) {
        var _this = this;
        return function() {
          return JH.GetUser(function(user) {
            JH.user = user;
            _this.updateLibrary(user.library);
            _this.addCostSprites();
            JH.pointsText.setText("" + user.points + " <coin>");
            return _this.cardSprites[cardId].onClick(function() {});
          });
        };
      };

      Library.prototype.updateCostSprite = function(cardId) {
        var card, cardSprite, costSprite;
        card = this.cardsById[cardId];
        cardSprite = this.cardSprites[cardId];
        costSprite = this.createCostSprite(cardSprite, card.cost, JH.user.points >= card.cost, this.library[cardId] != null);
        costSprite.position = {
          x: cardSprite.width / 2,
          y: cardSprite.height / 2
        };
        if (cardSprite.costSprite != null) {
          cardSprite.removeChild(cardSprite.costSprite);
        }
        cardSprite.costSprite = costSprite;
        return cardSprite.addChild(costSprite);
      };

      Library.prototype.addCostSprites = function() {
        var card, cardId, _ref, _results;
        _ref = this.cardsById;
        _results = [];
        for (cardId in _ref) {
          card = _ref[cardId];
          _results.push(this.updateCostSprite(cardId));
        }
        return _results;
      };

      Library.prototype.createCostSprite = function(cardSprite, cost, canAfford, isOwned) {
        var bg, bgcolor, container, text;
        container = new PIXI.DisplayObjectContainer;
        bgcolor = canAfford || isOwned ? 0x00BB00 : 0xBB0000;
        text = null;
        if (isOwned) {
          text = new PIXI.Text("Purchased", GUI.STYLES.TEXT);
        } else {
          text = new GUI.GlyphText("" + cost + " <coin>");
          text.position = {
            x: -text.width / 2,
            y: -text.height / 2
          };
        }
        bg = new PIXI.Graphics();
        bg.beginFill(bgcolor);
        bg.width = cardSprite.width;
        bg.height = text.height + COST_SPRITE_PADDING;
        bg.drawRect(-bg.width / 2, -bg.height / 2, bg.width, bg.height);
        text.anchor = {
          x: 0.5,
          y: 0.5
        };
        container.addChild(bg);
        container.addChild(text);
        container.width = bg.width;
        container.height = bg.height;
        return container;
      };

      return Library;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
