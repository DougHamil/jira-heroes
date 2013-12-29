util = require './util'
config =
  sessionSecret: 'JIRA_HEROES_TEST'

server = require('../src/server')(config)
require('../lib/controllers/user')(server.app, util.Users)
require('../lib/controllers/battle')(server.app, util.Users)
require('../lib/controllers/card')(server.app, util.Users)
require('../lib/controllers/deck')(server.app, util.Users)
require('../lib/controllers/hero')(server.app, util.Users)
server.app.listen(util.port)
module.exports = server
