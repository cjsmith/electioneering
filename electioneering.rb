require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'

set :port, 8080

candidates = ['science', 'math']

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/electioneering.db")

class Votes 
    include DataMapper::Resource
    property :id, Serial
    property :ip, String
    property :candidate, String
end

DataMapper.finalize

Votes.auto_upgrade!

def display_candidate(candidate)
    "<li><form method='post' action='/vote/#{candidate}'>#{candidate}<input value='vote' type='submit'/></form></li>"
end

get '/' do
    "<h2>Pick one:</h2><ol>" + candidates.map{|candidate| display_candidate(candidate)}.join('<br/>') + "</ol>"
end	

post '/vote/:candidate' do
    Votes.create(:ip => @env['REMOTE_ADDR'], :candidate => params[:candidate])
    redirect '/results'
end

get '/results' do
    candidates.map{|candidate| "<li>#{candidate} = #{Votes.count(:candidate => candidate).to_s}</li>"}.join('<br>')
end



