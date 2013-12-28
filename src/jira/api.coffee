http = require 'http'
CONFIG = require '../config'

exports.getIssueHistoryForUserSince = (time, user, username, password, cb) ->
  path = "/rest/api/2/search?fields=comment,*all&maxResults=100&expand=changelog&jql="+encodeURIComponent("(assignee = "+user+" OR assignee was "+user+" ) AND Updated >= #{time}")
  console.log path
  http.request(
    {
      host: CONFIG.JIRA_HOST
      port: CONFIG.JIRA_PORT
      path:path
      headers:
        'Authorization': authHeader(username, password)
    }, tryParseResponse(cb)
  ).end()

getClosedIssuesSince = (time, username, password, cb) ->
  http.request(
    {
      host: CONFIG.JIRA_HOST
      port: CONFIG.JIRA_PORT
      path:'/rest/api/2/search?fields='+CONFIG.STORY_POINTS_FIELD+'&jql='+closedIssuesQuery(username, time)
      headers:
        'Authorization': authHeader(username, password)
    }, tryParseResponse(cb)
  )
  .end()

exports.getTotalStoryPointsSince = (time, ignoreIssueKeys, username, password, cb) ->
  # Get Closed issues
  getClosedIssuesSince time, username, password, (err, json) ->
    if err?
      cb err, json
    else
      keys = []
      points = 0
      for issue in json.issues
        if issue.key not in ignoreIssueKeys
          points += issue.fields[CONFIG.STORY_POINTS_FIELD] ? 0
        keys.push(issue.key)
      cb null, points, keys

exports.getUser = (username, password, cb) ->
  http.request(
    {
      host: CONFIG.JIRA_HOST
      port: CONFIG.JIRA_PORT
      path: '/rest/api/2/user?username='+username
      headers:
        'Authorization': "Basic " + new Buffer(username + ":" + password).toString('base64')
    }
    , tryParseResponse(cb))
  .end()

tryParseResponse = (cb) ->
  return (res) ->
    data = ''
    res.on 'data', (chunk) ->
      data += chunk
    res.on 'end', () ->
      try
        cb null, JSON.parse(data)
      catch err
        cb err, data

authHeader = (username, password) ->
  return "Basic "+new Buffer(username + ":" + password).toString('base64')

closedIssuesQuery = (username, time) ->
  return encodeURIComponent('assignee="'+username+'" AND Status WAS NOT "Closed" BEFORE "'+time+'" AND Status = "Closed"')

exports.getDateTime = ->
  date = new Date()
  year = date.getFullYear()
  month = date.getMonth() + 1
  month = if month < 10 then "0"+month else month
  day = date.getDate()
  day = if day < 10 then "0"+day else day
  hour = date.getHours()
  hour = if hour < 10 then "0"+hour else hour
  minute = date.getMinutes()
  minute = if minute < 10 then "0"+minute else minute

  return year+"/"+month+"/"+day+" "+hour+":"+minute
