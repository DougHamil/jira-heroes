config =
  sessionSecret: 'JIRA_HEROES_TEST'

module.exports = require('../src/server')(config)
