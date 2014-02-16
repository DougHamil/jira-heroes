Gifts = require '../models/gift'

module.exports = (app, Users) ->

  _validateGift = (user, gift) ->
    if not gift?
      return "Gift expected"
    if not gift.storyPoints? or not gift.bugsClosed? or not gift.bugsReported?
      return "No gift data provided"

    totalGiftSize = 0
    if gift.storyPoints?
      totalGiftSize += gift.storyPoints
    if gift.bugsClosed?
      totalGiftSize += gift.bugsClosed
    if gift.bugsReported?
      totalGiftSize += gift.bugsReported
    if totalGiftSize <= 0
      return "Expected value greater than 0"
    if gift.storyPoints? and user.wallet.storyPoints < gift.storyPoints
      return "Not enough funds"
    if gift.bugsClosed? and user.wallet.bugsClosed < gift.bugsClosed
      return "Not enough funds"
    if gift.bugsReported? and user.wallet.bugsReported < gift.bugsReported
      return "Not enough funds"

    if gift.storyPoints?
      user.wallet.storyPoints -= gift.storyPoints
    if gift.bugsClosed?
      user.wallet.bugsClosed -= gift.bugsClosed
    if gift.bugsReported?
      user.wallet.bugsReported -= gift.bugsReported

    return null

  _claimGift = (user, gift) ->
    if gift.storyPoints?
      user.wallet.storyPoints += gift.storyPoints
    if gift.bugsReported?
      user.wallet.bugsReported += gift.bugsReported
    if gift.bugsClosed?
      user.wallet.bugsClosed += gift.bugsClosed

  # Get gifts for user
  app.get '/secure/gift', (req, res) ->
    Gifts.getGiftsFor req.session.user._id, (err, gifts) ->
      if err?
        res.send 500, err
      else
        res.json gifts

  # Claim a gift
  app.post '/secure/gift/:id/claim', (req, res) ->
    id = req.params.id
    Gifts.get id, (err, gift) ->
      if err?
        res.send 500, err
      else if not gift?
        res.send 400, "Bad gift ID: #{id}"
      else
        Users.fromSession req.session.user, (err, user) ->
          if gift.to isnt user._id.toString()
            res.send 400, "Not your gift to claim"
          else
            _claimGift user, gift.gift
            user.save (err) ->
              if err?
                res.send 500, err
              else
                gift.remove (err) ->
                  if err?
                    res.send 500, err
                  else
                    res.send 200

  # Create a gift
  app.post '/secure/gift', (req, res) ->
    to = req.body.to
    gift = req.body.gift
    if not to? or not gift?
      res.send 400, "Expected 'to' and 'gift'"
    else
      Users.fromSession req.session.user, (err, user) ->
        if err?
          res.send 500, err
        else
          Users.getByName to, (err, toUser) ->
            if err? or not toUser?
              res.send 400, "Unknown user #{to}"
            else
              # Validate and withdraw funds for this gift
              err = _validateGift(user, gift)
              if err?
                res.send 400, err
              else
                Gifts.create user._id.toString(), user.name, toUser._id.toString(), gift, (err) ->
                  if err?
                    res.send 500
                  else
                    user.save (err) ->
                      if err?
                        res.send 500, err
                      else
                        res.send 200

