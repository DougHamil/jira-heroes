util = require './util'
config =
  sessionSecret: 'JIRA_HEROES_TEST'

server = require('../src/server')(config)
require('../lib/controllers/user')(server.app, util.Users)
server.app.listen(util.port)
module.exports = server
