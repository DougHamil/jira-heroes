express        = require 'express'
login = require '../lib/middleware/login'

module.exports = (config) ->
  # Init web server
  secret       = config.sessionSecret
  sessionStore = config.sessionStore || new express.session.MemoryStore()
  sessionKey   = config.sessionKey || 'connect.sid'
  cookieParser = express.cookieParser(secret)

  app = express()
  app.use express.bodyParser()
  app.use cookieParser
  app.use express.session({store:sessionStore, secret: secret, key:sessionKey})
  app.use express.static('public')
  app.use login()
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'

  out =
    app:app
    sessionStore:sessionStore
    cookieParser:cookieParser
