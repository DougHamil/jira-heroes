###
# Provides a simple login middleware layer that ensures a login is provided for access to any url
# under the /secure path. If a dev username/password is provided, then the user will automatically be logged in.
###
module.exports = ->
  (req, res, next) ->
    if req.url.indexOf('/secure') is 0
      if not req.session.user?
        req.session.redir = req.url
        res.redirect '/login'
      else
        req.user = req.session.user
        next()
    else
      req.user = req.session.user
      next()

