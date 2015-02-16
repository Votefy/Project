require 'sinatra'
require 'sqlite3'
require 'httparty'
require "awesome_print"
# require 'pry'

db = SQLite3::Database.new "playlist.db" #connecting to the database.

get '/songs' do
  playlist = db.execute("SELECT * FROM playlist ORDER BY votes DESC") #showing the playlist and ordering it by votes.
  puts playlist.ai 
  erb :index, locals: {playlist: playlist} #playlist is out table name.
end

post '/songs' do
  response = HTTParty.get("https://api.spotify.com/v1/search", :query => {:q => "artist:\"#{params['artist']}\" track:\"#{params['track']}\"",:type => 'track'})
  #the / is getting us out of quotes.
  #this is making the API call and getting that info.
  if response["tracks"]["total"] != 0
    track_ID = response["tracks"]["items"][0]["id"];
    #this is is adding what we want into the db.
    playlist = db.execute("INSERT INTO playlist (artist, track, track_ID) VALUES (?, ?, ?)", params["artist"], params["track"], track_ID)
    redirect '/songs'
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
