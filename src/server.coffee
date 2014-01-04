express        = require 'express'
path = require 'path'
login = require '../lib/middleware/login'
require 'colors'
console.flag = ->
  console.log "<<<<<<<<<<<<<< FLAG >>>>>>>>>>>>>>>".yellow

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
  app.set 'views', path.join(process.cwd(), 'lib/views')
  app.set 'view engine', 'jade'

  out =
    app:app
    sessionStore:sessionStore
    cookieParser:cookieParser
