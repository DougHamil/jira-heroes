require.config
  baseUrl: 'js/game'
  shim:
    tween:
      exports: 'TWEEN'
  paths:
    jquery: '../lib/jquery'
    pixi: '../lib/pixi'
    jiraheroes: '../lib/jiraheroes'
    engine: '../lib/engine'
    tween: '../lib/tween'
    util: '../lib/util'
    gui: './gfx/gui'

define ['jquery', 'jiraheroes', 'engine', 'gui', './viewmanager'], ($, JH, engine, GUI, ViewManager) ->
  $(document).ready ->
    engine.stage.setInteractive(true)
    viewManager = new ViewManager engine.stage
    viewManager.activateView 'MainMenu'
