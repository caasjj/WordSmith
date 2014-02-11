require 'sinatra'
require "sinatra/reloader" if development?
require 'active_record'
require 'digest/sha1'
require 'pry'
require 'uri'
require 'open-uri'
require 'digest/sha1'
require 'firebase'

###########################################################
# Configuration
###########################################################
configure :development, :production do
    ActiveRecord::Base.establish_connection(
       :adapter => 'sqlite3',
       :database =>  'db/dev.sqlite3.db'
     )
end

# Grab the current logged in player - which may be nil
before do
  @loggedInPlayer =  Player.find_by_id(session[:player_id]) 
end

# Handle potential connection pool timeout issues
after do
    ActiveRecord::Base.connection.close
end

# turn off root element rendering in JSON
ActiveRecord::Base.include_root_in_json = false

# Here, we will create the rooms 
base_uri = 'https://wordsmith.firebaseio.com/'
players_uri = "#{base_uri}players/"

firebase = { :firebase => Firebase.new(base_uri),
             :base_uri => 'https://wordsmith.firebaseio.com/',
             :players_uri => "#{base_uri}players/",
             :currentWord_uri => "#{base_uri}currentWord/",
             :maxValue_uri => "#{base_uri}maxValue/",
            }

# Read the playes from Firebase
# players = Firebase.get(players_uri)
# p players
def createCurrentWord(word, fb)
  fb[:firebase].set('currentWord', word)
end

def createMaxValue(fb)
  fb[:firebase].set('maxValue', 0)
end

def createPlayer(name, fb)
  p name
  ref = fb[:firebase].push(fb[:players_uri], {:username => name, :letters => ""}).body["name"]
  Player.destroy_all(:username => name)
  Player.create({:username => name, :lastname => ref})
end

def getPlayerRef(username)
  player = Player.find_by_username(username)
  player[:lastname] unless !player
end

def getPlayer(id, fb)
  player = fb[:firebase].get("#{fb[:players_uri]}#{id}")
  player.body unless !player
end

def getPlayerLetters(id, fb)
  p id
  player = getPlayer(id,fb)
  if (player != nil)
    player["letters"].to_s
  else
    nil
  end
end

def updatePlayerLetters(id, letters, fb)
  p id
  player = getPlayer(id, fb)
  if player
    player["letters"] = letters
    fb[:firebase].update("#{fb[:players_uri]}#{id}", player).body
  end
end

def appendCharToPlayerLetters(id, char, fb)
  p "appending character #{char} to user id #{id}"
  letters = getPlayerLetters(id, fb)
  letters << char[0,1] unless !char
  updatePlayerLetters(id, letters, fb)
  appendCharToCurrentWord(char, fb) unless !char
end

def deleteAllPlayers(fb)
  p 'deleting all players'
  fb[:firebase].delete(fb[:players_uri])
end

def getCurrentWord(fb)
  fb[:firebase].get(fb[:currentWord_uri]).body
end

def setCurrentWord(word, fb)
  fb[:firebase].set(fb[:currentWord_uri], word)
end

def appendCharToCurrentWord(char, fb)
  p "CurrentWord: #{getCurrentWord(fb)}"
  word = getCurrentWord(fb)
  word << char[0,1]
  setCurrentWord( word, fb )
  updateMaxValueForCurrentWord(word, fb)
end

def setMaxValue(value, fb)
  p "Setting maxValue to #{value}"
  fb[:firebase].set(fb[:maxValue_uri], value)
end

def updateMaxValueForCurrentWord(word, fb)
  p ("SELECT MAX(points),id,points,word AS max,id,points,word from dicts WHERE word LIKE '#{word}%'").to_json
  max = Dict.find_by_sql("SELECT MAX(points),id,points,word AS max,id,points,word from dicts WHERE word LIKE '#{word}%'")
  max = max[0].points || 0
  setMaxValue(max, fb)
end

#deleteAllPlayers(firebase)
createCurrentWord('', firebase)
createMaxValue(firebase)
# updatePlayerWord(player1, 'Salut!', firebase)
# updatePlayerWord(player2, 'Got you!', firebase)
# p "Player 1's word is: #{getPlayerWord(player1, firebase)}"
# p getPlayerWord(player2, firebase)
###########################################################
# Session
###########################################################
# set up session 
set :sessions => true
register do
  def auth (type)
    condition do
      if (session[:player_id] != nil)
        player = Player.find_by_id(session[:player_id])
        id = player.id unless !player
      end
      p session[:player_id], ':', id
      redirect "/login" unless session[:player_id] && session[:player_id] == id
    end
  end
end

###########################################################
# Models
###########################################################
class Dict < ActiveRecord::Base
end

class Score < ActiveRecord::Base
    belongs_to :game
    belongs_to :player
end

class Player < ActiveRecord::Base
    has_many :scores
    has_many :games, through: :scores
end

class Game < ActiveRecord::Base
    has_many :scores
    has_many :players, through: :scores
end

###########################################################
# Routes - Login and account creation
###########################################################
get '/', :auth => :player do
    p 'Serving index.html'
    File.read(File.join('public', 'index.html'))
end

get '/login' do
  File.read(File.join('public/html', 'login.html'))
end

post '/logout' do
  session[:player_id] = nil
  @loggedInUser = nil
  p session
  redirect to '/'
end

post '/login' do
  player = Player.find_by_username(params[:username])
  if player && player.password_hash == Digest::SHA1.hexdigest(params[:password] + player.salt)[0,63]
    session[:player_id] = player.id
    redirect to '/'  
  else
    session[:player_id] = nil
    p 'Login Failed!'
    puts player, player.password_hash, player.salt unless !player
    redirect to '/login'
  end
end

post '/players' do
  if params[:password] != params[:password_confirmation]
    puts "Password #{params[:password]} doesn't match #{params[:password_confirmation]}"
    return "passwords don't match!"#redirect to '/login' # TODO display message instead?
  end
  username  = params[:username]
  firstname = params[:firstname]
  lastname  = params[:lastname]
  email     = params[:email]
  fb_id     = params[:fb_id]
  salt = Digest::SHA1.hexdigest( Random.rand( 10**10 ).to_s )
  password_hash = Digest::SHA1.hexdigest(params[:password]+ salt)[0,63]
  Player.create(username: username, password_hash: password_hash, salt: salt, firstname: firstname, lastname: lastname, email: email)
  session[:player_id] = Player.find_by_username( username ).id
  redirect to '/'
end

###########################################################
# Routes - Game Creation and Scoring
###########################################################
get '/game/reset' do
  puts 'CLEARING THE GAME'
  deleteAllPlayers(firebase)
  setCurrentWord("", firebase)
  setMaxValue(0, firebase)
end

# Player creation interface
post '/players/:username' do
  createPlayer(params[:username], firebase)
end

post '/games/:game_id' do
  puts 'Player joins a game with game_id ', params[:game_id]
end

# Player character interface
get '/players/:id/char' do
  getPlayerLetters(params[:id], firebase)
end

post '/players/:id/char/:char' do
  # chars = getPlayerLetters(params[:id], firebase)
  # chars << params[:char][0,1]
  p 'Player #{params[:id]} posted character #{params[:char]}'
  id = getPlayerRef( params[:id] )
  appendCharToPlayerLetters(id, params[:char], firebase)
  'OK'
end

post '/players/:id/char' do
  # chars = getPlayerLetters(params[:id], firebase)
  # chars << params[:char][0,1]
  p "Player #{params[:id]} posted character #{params[:char]}"
  appendCharToPlayerLetters(params[:id], params[:char], firebase)
end


## Dictionary database interface
get '/word/:ref' do
  word = Dict.find_by_word(params[:ref])
  word.to_json
end

get '/max/:ref' do
  p "SELECT MAX(points) AS max,id,points,word from dicts WHERE word LIKE '#{params[:ref]}%';"
  Dict.find_by_sql("SELECT MAX(points) AS max,id,points,word from dicts WHERE word LIKE '#{params[:ref]}%';").to_json
end

## Scoring interface
get '/games/:game_id/scores' do
  puts 'Look up players and return all scores'
end
