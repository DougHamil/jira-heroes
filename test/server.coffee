util = require './util'
config =
  sessionSecret: 'JIRA_HEROES_TEST'

global.isTest = true
server = require('../src/server')(config)
server.app.isTest = true
require('../lib/controllers/user')(server.app, util.Users)
require('../lib/controllers/battle')(server.app, util.Users)
require('../lib/controllers/card')(server.app, util.Users)
require('../lib/controllers/deck')(server.app, util.Users)
require('../lib/controllers/hero')(server.app, util.Users)
expressServer = server.app.listen(util.port)
require('../src/game/server')(expressServer, server.sessionStore, server.cookieParser, util.Users)
module.exports = server
