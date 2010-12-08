require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'

set :port, 8080

candidate_names = ['science', 'math']

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

class Candidates
    include DataMapper::Resource
    property :id, Serial
    property :name, String
    property :num_votes, Integer
end

class Voters 
    include DataMapper::Resource
    property :id, Serial
    property :ip, String
    property :num_votes, Integer
end

DataMapper.finalize

Candidates.auto_upgrade!

def display_candidate(candidate_name)
    "<li><form method='post' action='/#{candidate_name}'>#{candidate_name}<input value='vote' type='submit'/></form></li>"
end

get '/' do
    "<h2>Pick one:</h2><ol>" + candidate_names.map{|candidate_name| display_candidate(candidate_name)}.join('<br/>') + "</ol>"
end	

post '/:name' do
    name = params[:name]
    candidate = Candidates.first_or_create(:name => name)
    p "Your IP address is #{ @env['REMOTE_ADDR'] }"	
    candidate.num_votes = candidate.num_votes.nil? ? 1 : candidate.num_votes + 1
    candidate.save!	
    voter = Voters.first_or_create(:ip => @env['REMOTE_ADDR'])
    voter.num_votes = voter.num_votes.nil? ? 1 : voter.num_votes + 1
    voter.save! 
    redirect '/results'
end

get '/results' do
    Candidates.all.map{|candidate| "<li>#{candidate.name} = #{candidate.num_votes.to_s}</li>"}.join('<br>')
end



