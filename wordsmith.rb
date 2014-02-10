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

base_uri = 'https://wordsmith.firebaseio.com/'
firebase = Firebase.new(base_uri)
# response = firebase.push("todos", { :name => 'Pick the milk', :priority => 1 })

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
    File.read(File.join('public', 'index.html'))
end

get '/login' do
 # erb :login
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
  salt = Digest::SHA1.hexdigest( Random.rand( 10**10 ).to_s )
  password_hash = Digest::SHA1.hexdigest(params[:password]+ salt)[0,63]
  Player.create(username: username, password_hash: password_hash, salt: salt, firstname: firstname, lastname: lastname, email: email)
  session[:player_id] = Player.find_by_username( username ).id
  redirect to '/'
end

###########################################################
# Routes - Game Creation and Scoring
###########################################################
post '/games' do
  puts 'Creates a new game'
end

post '/games/:game_id' do
  puts 'Player joins a game with game_id ', params[:game_id]
end

post '/games/:game_id/challenge' do
  puts 'Player challenged with type ', params[:challenge_type]
end

get '/word' do
  puts 'Look up word in Dictionary and get value'
end

get '/games/:game_id/scores' do
  puts 'Look up players and return all scores'
end
