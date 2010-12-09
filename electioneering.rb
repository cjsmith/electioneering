require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'haml'

set :port, 8080

Candidates = [ 'science', 'math' ] 
NumVotes = 3

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/electioneering.db")

class Votes 
  include DataMapper::Resource
  property :id, Serial
  property :ip, String
  property :candidate, String
end

DataMapper.finalize
Votes.auto_upgrade!

def times_voted(ip)
  Votes.count(:conditions => ['ip = ?', ip])
end

def vote(ip, candidate)
  Votes.create(:ip => ip, :candidate => candidate) 
end

def print_votes(candidate)
  num_votes = Votes.count(:conditions => ['candidate = ?', candidate])
  "#{candidate}: " + (num_votes == 1 ? "1 vote" : "#{num_votes} votes")
end

get '/' do
  redirect '/results' if times_voted(request.ip) >= 3 
  haml :candidates
end	

post '/vote/:candidate' do
  redirect '/results' if times_voted(request.ip) >= 3 
  vote(request.ip, params[:candidate])
  redirect '/'
end

get '/results' do
  haml :results
end

__END__

@@ layout
%html
  = yield

@@ candidates
%h3 Pick #{times_voted(request.ip) == 1 ? "Another":""} One #{times_voted(request.ip) == 2 ? "More":""}.
%ol
  - Candidates.each do |candidate|
    %li
      =candidate 
      %form{:method => "post", :action => "/vote/#{candidate}"}
        %input{:value => "vote", :type => "submit"}

@@ results
%h3 Results:
%ol
  - Candidates.each do |candidate|
    %li #{print_votes(candidate)}
