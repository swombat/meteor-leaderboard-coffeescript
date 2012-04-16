# Set up a collection to contain player information. On the server,
# it is backed by a MongoDB collection named "players."

Players = new Meteor.Collection "players"

reset_scores = ->
  players = []
  Players.find({}).forEach( (player)->
    players.push(player.name)
  )
  players.push(player.name) for player in Players.find({})
  Players.remove {}
  Players.insert {name: player, score: Math.floor(Math.random()*10)*5} for player in players

if Meteor.is_client
  Template.leaderboard.sort_by_name = -> Session.get("sort_by_name")

  Template.leaderboard.players = -> Players.find({}, {sort: (if Template.leaderboard.sort_by_name() then {name:1, score: -1} else {score: -1, name: 1}) })

  Template.leaderboard.selected_name = ->
    player = Players.findOne(Session.get("selected_player"))
    player && player.name

  Template.player.selected = -> if Session.equals("selected_player", this._id) then "selected" else ''

  Template.leaderboard.events = {
    'click input.inc': ->
      Players.update(Session.get("selected_player"), {$inc: {score: 5}})
    'click a#sort_by_name': ->
      Session.set "sort_by_name", true
    'click a#sort_by_score': ->
      Session.set "sort_by_name", false
    'click input.reset': ->
      reset_scores()
    'click input[name=add]': ->
      Players.insert name:$("input[name=name]").val()
    'keypress input[name=name]': (event)->
      Players.insert name:$("input[name=name]").val() if event.which is 13
  }

  Template.player.events = {
    'click': ->
      Session.set("selected_player", this._id)
    'click a.delete': ->
      Players.remove {_id: this._id}
    }

# On server startup, create some players if the database is empty.
if Meteor.is_server
  Meteor.startup(->
    if Players.find().count() is 0
      names = [
                "Ada Lovelace"
                "Grace Hopper"
                "Marie Curie"
                "Carl Friedrich Gauss"
                "Nikola Tesla"
                "Claude Shannon"
              ]
      Players.insert {name: name, score: Math.floor(Math.random()*10)*5} for name in names
  )
