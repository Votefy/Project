require 'sinatra'
require 'sqlite3'
require 'httparty'
require "awesome_print"
require 'json'
require 'pry'

db = SQLite3::Database.new "playlist.db" #connecting to the database.

get '/songs' do
  playlist = db.execute("SELECT * FROM playlist ORDER BY votes DESC") #showing the playlist and ordering it by votes.
  puts playlist.ai
  erb :index, locals: {playlist: playlist} #playlist is our table name.
end

get '/songs/play' do
  playlist = db.execute("SELECT * FROM playlist ORDER BY votes DESC")
  puts playlist.ai
  list_of_IDs = db.execute("SELECT track_ID, votes FROM playlist ORDER BY votes DESC")
  final_URL = "https://embed.spotify.com/?uri=spotify:trackset:VOTEFY:"
  array = []
  list_of_IDs.each do |id|
    if id[1] > 0
      track = id[0]
      array.push(track)
    end
  end
  array.each do |song|
    formatted = song + ","
    final_URL = final_URL + formatted
  end
  erb :show, locals: {playlist: playlist, final_URL: final_URL}
end

post '/songs' do
  response = HTTParty.get("https://api.spotify.com/v1/search", :query => {:q => "artist:\"#{params['artist']}\" track:\"#{params['track']}\"",:type => 'track'})
  #the / is getting us out of quotes.
  #this is making the API call and getting that info.
  if response["tracks"]["total"] != 0
    artist = response["tracks"]["items"][0]["artists"][0]["name"]
    track = response["tracks"]["items"][0]["name"]
    track_ID = response["tracks"]["items"][0]["id"]
    #this is is adding what we want into the db.
    playlist = db.execute("INSERT INTO playlist (artist, track, track_ID) VALUES (?, ?, ?)", artist, track, track_ID)
    redirect '/songs'
  else
    content_type :json
    data = "Spotify does not recognize this song."
    data.to_json
  end
end

put '/songs/:id/up' do
  playlist = db.execute("UPDATE playlist SET votes=(votes + 1) WHERE id=?",params[:id]) #we are adding the votes right here.
  redirect '/songs'
end

put '/songs/:id/down' do
  playlist = db.execute("UPDATE playlist SET votes=(votes - 1) WHERE id=?",params[:id])
  redirect '/songs'
end

delete '/songs/:id' do
  playlist = db.execute("DELETE FROM playlist WHERE id=(?)",params[:id])
  redirect '/songs'
 end
