require.config
  baseUrl: 'js/game'
  shim:
    tween:
      exports: 'TWEEN'
  paths:
    emitters: './battle/fx/emitters/factory'
    jquery: '../../lib/jquery'
    pixi: '../../lib/pixi'
    tween: '../../lib/tween'
    jiraheroes: '../jiraheroes'
    engine: '../engine'
    util: '../util'
    gui: './gfx/gui'
    eventemitter: '../eventemitter'
    battlehelpers: '../battlehelpers'
    proton: '../../lib/proton'

define ['jquery', 'jiraheroes', 'engine', 'gui', './viewmanager'], ($, JH, engine, GUI, ViewManager) ->
  $(document).ready ->
    JH.LoadStaticData ->
      engine.stage.setInteractive(true)
      viewManager = new ViewManager engine.stage
      viewManager.activateView 'MainMenu'
