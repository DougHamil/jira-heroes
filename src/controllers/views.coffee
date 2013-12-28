exports.init = (app) ->
  app.get '/', (req, res) ->
    if req.session.user?
      res.render 'index', { entryModule: 'game/main', user: req.session.user}
    else
      res.redirect '/login'
  app.get '/login', (req, res) ->
    data =
      failed: req.session.loginFailed?
      entryModule: 'login'
    delete req.session.loginFailed
    res.render 'login', data
  console.log 'Initialized views controller.'
