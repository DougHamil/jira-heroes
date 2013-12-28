// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['gfx/campaignmap', 'client/gamemanager', 'jiraheroes', 'gui', 'engine', 'pixi', 'tween'], function(CampaignMap, GameManager, JH, GUI, engine) {
    var Campaign;
    return Campaign = (function(_super) {
      __extends(Campaign, _super);

      function Campaign(manager, myStage) {
        this.manager = manager;
        this.myStage = myStage;
        Campaign.__super__.constructor.apply(this, arguments);
      }

      Campaign.prototype.deactivate = function() {
        this.myStage.removeChild(this);
        this.removeChild(this.heading);
        return this.gameManager.disconnect();
      };

      Campaign.prototype.activate = function(hero, campaign) {
        var _this = this;
        this.hero = hero;
        this.campaign = campaign;
        this.heading = new PIXI.Text("" + this.hero.name + " in " + this.campaign.name, GUI.STYLES.HEADING);
        this.addChild(this.heading);
        this.myStage.addChild(this);
        this.gameManager = new GameManager(this.hero, this.campaign);
        this.gameManager.on('disconnect', function() {
          alert('Disconnected from game server');
          return _this.manager.activateView('HeroMenu');
        });
        this.gameManager.on('joined', function(campaignData) {
          return _this.onCampaignJoined(campaignData);
        });
        this.gameManager.socket.on('heroMoved', function(heroId, node) {
          return _this.map.moveHero(heroId, node);
        });
        return this.gameManager.socket.on('heroJoined', function(hero, node) {
          return _this.map.addHero(hero, node);
        });
      };

      Campaign.prototype.onCampaignJoined = function(data) {
        var _this = this;
        console.log("Joined campaign");
        this.map = new CampaignMap(data);
        this.map.on('nodeClicked', function(node) {
          console.log("Node clicked: " + node);
          return _this.gameManager.moveTo(node, function(data) {
            if ((data != null) && (data.error != null)) {
              return console.log(err);
            } else {
              console.log(data);
              return _this.map.moveHero(_this.hero._id, node);
            }
          });
        });
        return this.addChild(this.map);
      };

      return Campaign;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
